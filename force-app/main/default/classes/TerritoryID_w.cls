public class TerritoryID_w {
    /*Insert header snipper here
*/
    
    //declare class vars
    private string zip;
    private string amid;
    private string pcid;
    private string rvpid;
    public MAP<String, String> dmlResults = new Map<String, String>();
    Territory_ID__c theTerritoryID = new Territory_ID__c();
    
    //insert context
    public TerritoryID_w(Territory_ID__c tid, String triggercontext){
        this.theTerritoryID = tid;
        this.zip = tid.Zip_Code__c;
        if(triggercontext.contains('before')){
            //currently we have no processes that require a before context
        }
    }
    
    //update context
    public TerritoryID_w(Territory_ID__c oldTid, Territory_ID__c newTid, String triggercontext){
        this.theTerritoryID = newTid;
        this.zip = newTid.Zip_Code__c;
        if(triggercontext.contains('before')){
            //currently we do not need a before context
        } else if(triggercontext.contains('after')){
            //if the Territory ID record is reassigned to a new Territory Name
            //the Accounts and their Child objects need to inherit the attrituvtes of the new Territory Name
            if(theTerritoryID.Territory_Name__c != oldTid.Territory_Name__c){
                updateChildObjects();
            }
        }
    }
    
    private void updateChildObjects(){
        //call the Utility to do a master re-query of the TerritoryID record in the trigger
        //so we can get the attributes of the new Territory Name
        TerritoryID_u tidu = new TerritoryID_U(theTerritoryID);
        theTerritoryID = tidu.theTid;
        system.debug('the results of the TID U query are ' + theTerritoryID);
        Set<Id> tnIds = new Set<Id>();
        tnIds.add(theTerritoryID.Territory_Name__r.Id);
        String amId = theTerritoryID.Territory_Name__r.User__c;
        Map<String, String> userRoleMap = new Map<String, String>();
        userRoleMap.put('pcid', theTerritoryId.Territory_Name__r.Program_Consultant__c);
        userRoleMap.put('rvpid', theTerritoryId.Territory_Name__r.Regional_VP__c);
        
        //NOTE: DEPENDING ON PERFORMANCE THESE BATCH CALLS MAY NEED TO BE CHAINED TOGETHER
        //INSTEAD OF CALLED SEPARATELY
        
        //batch update accounts
        AccountsUpdateBatch batchacctupdate = new AccountsUpdateBatch(tnIds, amId);
        Database.executeBatch(batchacctupdate, 10);
        
        //batch update account teams
        AccountTeamMembersBatch batchatmupdate = new AccountTeamMembersBatch(tnIds, userRoleMap);
        Database.executeBatch(batchatmupdate, 10);
        
        //batch update contacts
        ContactsUpdateBatch batchconupdate = new ContactsUpdateBatch(tnIds, amId);
        Database.executeBatch(batchconupdate, 10);
        
        //batch update opps
        OpportunitiesUpdateBatch batchoppupdate = new OpportunitiesUpdateBatch(tnIds, amId);
        Database.executeBatch(batchoppupdate, 10);
        
    }
    
}