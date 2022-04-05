public with sharing class Account_w {
    /*Insert header snipper here
*/

    //declare class vars
    private string zip;
    private List<Opportunity> relatedOpps = new List<Opportunity>();
    private List<Contact> relatedContacts = new List<Contact>();
    private List<AccountTeamMember> acctteam = new List<AccountTeamMember>();
    private string amid;
    private string pcid;
    private string rvpid;
    private Id acctId;
    public MAP<String, String> oppsUpdateResults = new Map<String, String>();
    public MAP<String, String> consUpdateResults = new Map<String, String>();
    public MAP<String, String> dmlResults = new Map<String, String>();
    Account theAccount = new Account();
    
    //called from insert handler
    public Account_w(Account account, String triggercontext){
        this.theAccount = account;
        this.zip = account.ShippingPostalCode;
        if(triggercontext.contains('before')){
            //Related Territory ID assignment if needed
            if(((zip != null && zip.length() == 5) || (theAccount.TerritoryOverride__c != null && theAccount.TerritoryOverride__c != 'Manual Input')) && theAccount.Related_TerritoryID__c == null){
                assignTerritoryId(triggercontext);
            }
        }
    }
    
    //called from update handler
    public Account_w(Account oldAccount, Account newAccount, String triggercontext){
        this.theAccount = newAccount;
        this.zip = newAccount.ShippingPostalCode;
        if(triggercontext.contains('before')){
            //can only update the record in the trigger in a 'before' context
            if(((zip != null && zip.length() == 5 && zip != oldAccount.ShippingPostalCode) || (theAccount.TerritoryOverride__c != null && theAccount.TerritoryOverride__c != 'Manual Input' && theAccount.TerritoryOverride__c != oldAccount.TerritoryOverride__c))){
                assignTerritoryId(triggercontext);
            }
        } else if(triggercontext.contains('after')){
            //can only update related child objects if the record has an ID which doesn't happen until after an insert
            if(theAccount.OwnerId != oldAccount.OwnerId){
                updateChildObjects();
            }
        }
    }
    
    //based on either the zip code or the override field seeks to assign a TerritoryID 
    //to the Related Territory ID field on the account - has to be a 'before' context
    private void assignTerritoryId(String triggercontext){
        //get matching Territory Ids based on either the zip or the override reason
        List<Territory_ID__c> recTerritoryIds = new List<Territory_ID__c>([Select Id, Territory_Name__r.User__c, Territory_Name__r.User__r.IsActive, Territory_Name__r.Program_Consultant__c, Territory_Name__r.Program_Consultant__r.IsActive, Territory_Name__r.Regional_VP__c, Territory_Name__r.Regional_VP__r.IsActive from Territory_ID__c where (Zip_Code__c = :zip or (Override_Reason__c = :theAccount.TerritoryOverride__c and Override_Reason__c != null))]);
        if(Utility.isNullorEmpty(recTerritoryIds) == false){
            //before reassigning ownership of records, we need to ensure the refernced user is active to avoid an error
            if(recTerritoryIds[0].Territory_Name__r.User__r.IsActive == true){
                amid = recTerritoryIds[0].Territory_Name__r.User__c;
            }
            if(recTerritoryIds[0].Territory_Name__r.Program_Consultant__r.IsActive == true){
                pcid = recTerritoryIds[0].Territory_Name__r.Program_Consultant__c;
            }
            if(recTerritoryIds[0].Territory_Name__r.Regional_VP__r.IsActive == true){
                rvpid = recTerritoryIds[0].Territory_Name__r.Regional_VP__c;
            }
            if(triggercontext.contains('update')){
                //instantiate account utility and do master account query to get necessary object and fields
                Account_u acctu = new Account_u(theAccount, true);//need to use Account_u to re-query trigger
                //record in an update context
                theAccount = acctu.theAccount;
                acctId = theAccount.Id;
                theAccount.Related_TerritoryID__c = recTerritoryIds[0].Id;
                system.debug('trigger context: ' + triggercontext + ' theAccount Owner ID BEFORE updating is ' + theAccount.OwnerId + ' and the AM ID on the TN is ' + amid);
                //determine if the AM on the related Territory has changed 
                if(amid != null && theAccount.OwnerId != amid){
                    theAccount.OwnerId = amid;
                    relatedOpps = acctu.relatedOpps;
                    relatedContacts = acctu.relatedContacts;
                    updateChildObjects();
                }
            } else if(triggercontext.contains('insert')){
                theAccount.Related_TerritoryID__c = recTerritoryIds[0].Id;
                system.debug('trigger context: ' + triggercontext + ' theAccount Owner ID BEFORE updating is ' + theAccount.OwnerId + ' and the AM ID on the TN is ' + amid);
                if(amid != null && theAccount.OwnerId != amid){
                    theAccount.OwnerId = amid;
                }
                if(triggercontext.contains('after')){
                    acctId = theAccount.Id;
                }
            }
        }
    }
    
    //if the account owner changes based on territory am assignment the related Contacts and Opportunities need to
    //be reassigned to the same AM
    private void updateChildObjects(){
        Boolean pcneeded = true;
        Boolean rvpneeded = true;
        Set<Id> teamids = new Set<Id>();
        Set<String> tmneeded = new Set<String>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Contact> contactsToUpdate = new List<Contact>();
        //create and/or maintain the Account Team based on the Program Consultant and RVP
        if(acctId != null && (pcid != null || rvpid != null)){
            acctteam = [Select Id, TeamMemberRole, UserId, AccountId from AccountTeamMember where AccountId = :acctId and (UserId = :pcid or UserId = :rvpid)];
            if(Utility.isNullorEmpty(acctteam) == false){
                for(AccountTeamMember atm : acctteam){
                    teamids.add(atm.UserId);
                }
            }
            if(pcid != null && !teamids.Contains(pcid)){
                tmneeded.add(pcid);
            }
            if(rvpid != null && !teamids.contains(rvpid)){
                tmneeded.add(rvpid);
            }
            If(tmneeded != null){
                String role;
                acctteam.clear();
                for(String tm : tmneeded){
                    if(tm == pcid){
                        role = 'Program Consultant';
                    } else role = 'Regional VP';
                    AccountTeamMember acctm = new AccountTeamMember(AccountId = acctId, UserId = tm, TeamMemberRole = role);
                    acctteam.add(acctm);
                }
            }
        }
        
        //reassign opps
        for(Opportunity opp : relatedOpps){
            if(opp.OwnerId != amid && opp.StageName != 'Closed Won'){
                opp.OwnerId = amid;
                oppsToUpdate.add(opp);
            }
        }
        
        //reassign contacts
        for(Contact con : relatedContacts){
            if(con.OwnerId != amid){
                con.OwnerId = amid;
                contactsToUpdate.add(con);
            }
        }
        
        //call batch jobs if needed
        if(Utility.isNullorEmpty(oppsToUpdate) == false){
            DMLOperations dmlops = new DMLOperations(oppsToUpdate, 'update');
            oppsUpdateResults = dmlops.DMLResults;
        }
        
        if(Utility.isNullorEmpty(contactsToUpdate) == false){
            DMLOperations dmlcons = new DMLOperations(contactsToUpdate, 'update');
            consUpdateResults = dmlcons.dmlresults;
        }
        
        if(Utility.isNullorEmpty(acctteam) == false){
            DMLOperations dmlcons = new DMLOperations(acctteam, 'insert');
            consUpdateResults = dmlcons.dmlresults;
        }
        
        //populate results for logging
        dmlResults.putAll(oppsUpdateResults);
        dmlResults.putAll(consUpdateResults);
        system.debug(dmlResults);
    }  
}