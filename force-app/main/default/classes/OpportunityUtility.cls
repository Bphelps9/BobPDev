/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class for operations on Opportunity records
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ehtiram Mammadzada <edd.mammadzada@gmail.com>
* @version        1.0
* @created        27-07-2021
* @systemLayer    Utility
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class OpportunityUtility {

    /**
    * @description Set owners of the given Accounts as owners of related open Opportunities
    * @param accMap Map with Account IDs set as key and Account records set as value
    */
    public static void setRelatedOpenOpportunityOwner(Map<Id, Account> accMap) {
        // Collect the "Open" stage values
        Set<String> openStages = new Set<String>();
        for (OpportunityStage stg: [SELECT Id, ApiName FROM OpportunityStage WHERE IsClosed = false]) {
			openStages.add(stg.ApiName);
        }
        // Retrieve the open Opportunities of given Accounts
        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accMap.keySet() AND StageName IN :openStages];
        if (!opps.isEmpty()) {
            for (Opportunity opp: opps) {
                opp.OwnerId = accMap.get(opp.AccountId).OwnerId;
            }
            update opps;
        }
    }
}