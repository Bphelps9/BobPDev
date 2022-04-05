public class OpportunityTriggerHandler {

    public OpportunityTriggerHandler() {}
    
    public void run() {
        if (Trigger.isAfter && Trigger.isUpdate) {
            // afterUpdate();
        }
    }
/* OBSOLETE METHOD - TERRITORY HIERARCHY DISABLED
    // Opportunity territories are calculated on afterUpdate since the territory assignment class utilizes a SOQL query to get Opportunity details
    // When using beforeUpdate query returns the previous AccountId value
	private void afterUpdate() {
        List<Id> territoryRecalcList = new List<Id>();
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>)Trigger.oldMap;
        List<Opportunity> newList = (List<Opportunity>)Trigger.new;
        // Collect all opportunity IDs
        for (Opportunity opp: newList) {
            // Replicate the logic of the Territory manangement and ensure that only Opportunities with
            // IsExcludedFromTerritory2Filter set to false are included in territory assignment process
            if (!opp.IsExcludedFromTerritory2Filter) {
            	Opportunity oldOpp = oldMap.get(opp.Id);
                if (oldOpp.AccountId != opp.AccountId && !String.isBlank(opp.AccountId)) {
                    territoryRecalcList.add(opp.Id);
                }
            }
        }
        // Calculate and retrieve the territory map, then update the territory fields on opportunities
        Map<Id, Id> territoryMap = new OpportunityTerritoryAssignment().getOpportunityTerritory2Assignments(territoryRecalcList);
        if (!territoryMap.isEmpty()) {
        	updateTerritory2Id(territoryMap);
        }        
    }
    
    @future
    private static void updateTerritory2Id(Map<Id, Id> oppTerritoryMap) {
        List<Opportunity> oppList = new List<Opportunity>();
        for (Id oppId: oppTerritoryMap.keySet()) {
            Opportunity opp = new Opportunity(Id = oppId);
            opp.Territory2Id = oppTerritoryMap.get(oppId);
            oppList.add(opp);
        }
        update oppList;
    }
*/
}