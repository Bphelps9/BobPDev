public class TerritoryName_h {
    /*insert class heading snippet here
* Handler class to determine trigger context and whether to instantiate the wrapper class
* 
*/
    //declare class vars
    private List<TerritoryName__c> oldTerritoryNames = new List<TerritoryName__c>();
    private List<TerritoryName__c> newTerritoryNames = new List<TerritoryName__c>();
    private Map<Id, TerritoryName__c> oldTerritoryNamesMap = new Map<Id, TerritoryName__c>();
    private Map<Id, TerritoryName__c> newTerritoryNamesMap = new Map<Id, TerritoryName__c>();
    private string triggercontext;
    
    //default constructor
    public TerritoryName_h(){
        
    }
    
    public void beforeInsert(List<TerritoryName__c> tns){
        this.newTerritoryNames = tns;
        triggercontext = 'before insert';
        wrapper(triggercontext);
    }
    
    public void afterInsert(List<TerritoryName__c> tns){
        this.newTerritoryNames = tns;
        triggercontext = 'after insert';
        wrapper(triggercontext);
    }
    
    public void beforeUpdate(List<TerritoryName__c> tns, Map<Id, TerritoryName__c> oldTNsMap){
        this.newTerritoryNames = tns;
        this.oldTerritoryNamesMap = oldTNsMap;
        triggercontext = 'before update';
        wrapper(triggercontext);
    }
    
    public void afterUpdate(List<TerritoryName__c> tns, Map<Id, TerritoryName__c> oldTNsMap){
        this.newTerritoryNames = tns;
        this.oldTerritoryNamesMap = oldTNsMap;
        triggercontext = 'after update';
        wrapper(triggercontext);
    }
    
    private void wrapper(String triggercontext) {
        if(triggercontext.contains('insert')){
            //currently Territory ID assignments to Territory Names are done manually and there is 
            //no automation needed at the time of record insert
        } else if(triggercontext.contains('update')){
            for(TerritoryName__c newtn : newTerritoryNames){
                TerritoryName_w tnWrapper = new TerritoryName_w(oldTerritoryNamesMap.get(newtn.Id), newtn, triggercontext);
                /*
if(tidWrapper.dmlResults != null || !tidWrapper.dmlResults.isempty()){
system.debug(accountWrapper.dmlResults); //TODO add some error handling and messaging
}
*/
            }
        }
    }
}