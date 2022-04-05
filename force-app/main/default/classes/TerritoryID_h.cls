public class TerritoryID_h {
    /*insert class heading snippet here
* Handler class to determine trigger context and whether to instantiate the wrapper class
* 
*/
    //declare class vars
    private List<Territory_ID__c> oldTerritoryIds = new List<Territory_ID__c>();
    private List<Territory_ID__c> newTerritoryIds = new List<Territory_ID__c>();
    private Map<Id, Territory_ID__c> oldTerritoryIdsMap = new Map<Id, Territory_ID__c>();
    private Map<Id, Territory_ID__c> newTerritoryIdsMap = new Map<Id, Territory_ID__c>();
    private string triggercontext;
    
    //default constructor
    public TerritoryID_h(){
        
    }
    
    
    public void beforeInsert(List<Territory_ID__c> tids){
        this.newTerritoryIDs = tids;
        triggercontext = 'before insert';
        wrapper(triggercontext);
    }
    
    public void afterInsert(List<Territory_ID__c> tids){
        this.newTerritoryIDs = tids;
        triggercontext = 'after insert';
        wrapper(triggercontext);
    }
    
    public void beforeUpdate(List<Territory_ID__c> tids, Map<Id, Territory_ID__c> oldTidsMap){
        this.newTerritoryIDs = tids;
        this.oldTerritoryIDsMap = oldTidsMap;
        triggercontext = 'before update';
        wrapper(triggercontext);
    }
    
    public void afterUpdate(List<Territory_ID__c> tids, Map<Id, Territory_ID__c> oldTidsMap){
        this.newTerritoryIDs = tids;
        this.oldTerritoryIDsMap = oldTidsMap;
        triggercontext = 'after update';
        wrapper(triggercontext);
    }
    
    private void wrapper(String triggercontext) {
        if(triggercontext.contains('insert')){
            //currently we Territory ID assignments to Territory Names are done manually and there is 
            //no automation needed at the time of record insert
        } else if(triggercontext.contains('update')){
            for(Territory_ID__c newtid : newTerritoryIDs){
                TerritoryID_w tidWrapper = new TerritoryID_w(oldTerritoryIdsMap.get(newtid.Id), newtid, triggercontext);
                /*
if(tidWrapper.dmlResults != null || !tidWrapper.dmlResults.isempty()){
system.debug(accountWrapper.dmlResults); //TODO add some error handling and messaging
}
*/
            }
        }
    }
}