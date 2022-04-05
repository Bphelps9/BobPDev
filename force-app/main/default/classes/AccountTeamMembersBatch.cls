public class AccountTeamMembersBatch implements Database.Batchable<Sobject> {
    /* Author: Bob Phelps
*
*  Date Created: 03/28/2021
*
*  Purpose: Batch process to bulk update Account Teams
*
*  Notes:
*
*  Modification History:
*  Date / Author  / Description
*  -------------  ------------------  --------------------------------------------------------------------------------------------------------------
* */
    
    Set<Id> territoryNameIds;
    String pcId;
    String rvpId;
    
    //constructor for assigning Account Teams via the TerritoryName object
    public AccountTeamMembersBatch(Set<Id> TNIds, Map<String, String> TMMap) {
        this.territoryNameIds = TNIds;
        this.pcId = TMMap.get('pcid');
        this.rvpId = TMMap.get('rvpid');
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Getting the accounts attached to the TerritoryName to insert or change the team assignments
        String query = 'Select Id, OwnerId from Account where Related_TerritoryID__r.Territory_Name__r.Id in: territoryNameIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        //declare vars
        Set<Id> acctIds = new Set<Id>();
        Set<Id> acctIdsNeedingTeam = new Set<Id>();
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        List<AccountTeamMember> atmsToInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> atmsToDelete = new List<AccountTeamMember>();
        AccountTeamMember atmToInsert = new AccountTeamMember();
        Map<Id, List<String>> idRoleMap = new Map<Id, List<String>>();
        if(Utility.isNullorEmpty(accounts) == false){
            for (Account acct : accounts) {
                acctIds.add(acct.Id);
            }
            //do we have any Account Team Member Assignments already?
            atms = [Select Id, UserId, TeamMemberRole, AccountId from AccountTeamMember where AccountId in :acctIds];
            
            if(Utility.isNullorEmpty(atms) == true){//If not then we can just create all the ones passed to the batch
                for(Id acctId : acctIds){
                    if(pcid != null){
                        AccountTeamMember pcatm = new AccountTeamMember(AccountId = acctId, UserId = pcid, TeamMemberRole = 'Program Consultant');
                        atmsToInsert.add(pcatm);
                    }
                    if(rvpId != null){
                        AccountTeamMember rvpatm = new AccountTeamMember(AccountId = acctId, UserId = rvpid, TeamMemberRole = 'Regional VP');
                        atmsToInsert.add(rvpatm);
                    }
                }
            } else{
               //if we do have Account Team Member Assignments we have to see if they match 
               //the assignments on the Terriotry Name passed to the batch
                for(AccountTeamMember atm : atms){
                    if(atm.TeamMemberRole == 'Regional VP' &&  atm.UserId != rvpId){
                        //can't update the atm so I need to create a new one by cloning and then delete the old one
                        atmToInsert = atm.clone();
                        atmToInsert.UserId = rvpId;
                        atmsToInsert.add(atmToInsert);
                        atmsToDelete.add(atm);
                    } else if(atm.TeamMemberRole == 'Program Consultant' && atm.UserId != pcId){
                        atmToInsert = atm.clone();
                        atmToInsert.UserId = pcId;
                        atmsToInsert.add(atmToInsert);
                        atmsToDelete.add(atm);
                    }
                }
            }
            if(Utility.isNullorEmpty(atmsToInsert) == false){
                DMLOperations dmlupdate = new DMLOperations(atmsToInsert, 'insert');
            }
            if(Utility.isNullorEmpty(atmsToDelete) == false){
                DMLOperations dmlupdate = new DMLOperations(atmsToDelete, 'delete');
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()
        ];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ a.CreatedBy.Email };
            mail.setToAddresses(toAddresses);
        mail.setSubject('Account Owners Updated ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems + 'with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}