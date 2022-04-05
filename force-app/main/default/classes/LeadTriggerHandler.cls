public class LeadTriggerHandler {
    
    public static Boolean bypassTrigger = false;
    
    public LeadTriggerHandler() {}
    
    public void run() {
        if (bypassTrigger == true) {
            return;
        }
        
        if (Trigger.isBefore && Trigger.isInsert) {
            assignCustomTerritories(Trigger.new);
        }
        else if (Trigger.isBefore && Trigger.isUpdate) {
            assignCustomTerritories(Trigger.new);
        }
    }
    
    public static void assignCustomTerritories(List<Lead> leads) {
        Set<String> postalCodes = new Set<String>();
        for (Lead l: leads) {
            postalCodes.add(l.PostalCode);
        }
        TerritoryAssignmentHandler handler = new TerritoryAssignmentHandler(postalCodes, 'Lead', null);
        for (Lead l: leads) {
            TerritoryAssignmentHandler.TerritoryStruct territoryDetails = handler.getTerritoryDetails(l.Id, l.PostalCode, null);
            l.Territory_ID__c = territoryDetails.territoryNumber;
            l.Territory_Name__c = territoryDetails.territoryId;
            l.AM__c = territoryDetails.am;
            l.RVP__c = territoryDetails.rvp;
            l.PC__c = territoryDetails.pc;
            l.State__c = territoryDetails.state;
            l.County__c = territoryDetails.county;
            l.OwnerId = territoryDetails.amId != null ? territoryDetails.amId : l.OwnerId;
        }
    }
}