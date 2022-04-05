public class TerritoryName_w {
    /*Insert header snipper here
*/
    //declare class vars
    private string amid;
    private string pcid;
    private string rvpid;
    Map<String, String> teamMap = new Map<String, String>();
    public MAP<String, String> dmlResults = new Map<String, String>();
    TerritoryName__c theTerritoryName = new TerritoryName__c();
    
    //before insert trigger context - only passing trigger.new here
    public TerritoryName_w(TerritoryName__c tn, String triggercontext){
        this.theTerritoryName = tn;
        if(triggercontext.contains('before')){
            //currently we have no processes that require a before context
        }
    }
    
    //update trigger context
    public TerritoryName_w(TerritoryName__c oldTn, TerritoryName__c newTn, String triggercontext){
        this.theTerritoryName = newTn;
        if(triggercontext.contains('before')){
            //currently we do not need a before context
        } else if(triggercontext.contains('after')){
            //if the AM on the Territory Name record changes, then we have to update ownership of child records as well
            if(theTerritoryName.User__c != oldTn.User__c){
                updateChildObjects();
            }
            //if the PC and/or the RVP changes on the record, then we need to update the Account Teams for the
            //accounts related to the Territory name
            Set<Id> tnIds = new Set<Id>();
            if(theTerritoryName.Program_Consultant__c != oldTn.Program_Consultant__c){
                teamMap.put('pcid', theTerritoryName.Program_Consultant__c);
                tnIds.add(theTerritoryName.Id);
            }
            if(theTerritoryName.Regional_VP__c != oldTn.Regional_VP__c){
                teamMap.put('rvpid', theTerritoryName.Regional_VP__c);
                tnIds.add(theTerritoryName.Id);
            }
            //call batch job starting with batch size of 10, can play with batch size
            if(teamMap != null || !teamMap.isempty()){
            AccountTeamMembersBatch batchatmupdate = new AccountTeamMembersBatch(tnIds, teamMap);
            Database.executeBatch(batchatmupdate, 10);
            }
        }
    }
    
    //here is where we reassign the ownership of the related records to the accounts that had a territory Name change
    private void updateChildObjects(){
        TerritoryName_u tnu = new TerritoryName_U(theTerritoryName);
        theTerritoryName = tnu.theTn;
        system.debug('the results of the TN U query are ' + theTerritoryName);
        Set<Id> tnIds = new Set<Id>();
        tnIds.add(theTerritoryName.Id);
        String amId = theTerritoryName.User__c;

            AccountsUpdateBatch batchacctupdate = new AccountsUpdateBatch(tnIds, amId);
            Database.executeBatch(batchacctupdate, 10);
            
            ContactsUpdateBatch batchconupdate = new ContactsUpdateBatch(tnIds, amId);
            Database.executeBatch(batchconupdate, 10);
            
            OpportunitiesUpdateBatch batchoppupdate = new OpportunitiesUpdateBatch(tnIds, amId);
            Database.executeBatch(batchoppupdate, 10);

    }

    }