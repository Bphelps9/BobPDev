/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class for operations on Account records
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ehtiram Mammadzada <edd.mammadzada@gmail.com>
* @version        1.0
* @created        27-07-2021
* @systemLayer    Utility
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class AccountUtility {

    /**
    * @description Determine and set the Parents of the Accounts based on the Parent NCES ID value
    * @param accList List of Accounts to determine the parents for
    */
    public static void setParentAccounts(List<Account> accList) {
        List<String> parentNcesIds = new List<String>();
        List<Account> filteredAccs = new List<Account>();
        for (Account acc: accList) {
            // Only accounts with populated Parent NCES ID values should be processed
            if (acc.ParentNcesId__c != null) {
                filteredAccs.add(acc);
                parentNcesIds.add(acc.ParentNcesId__c);
            }
        }
        // Retrieve the Parent Accounts using collected NCES IDs and set the parent lookup value
        populateParentAccountId(parentNcesIds, filteredAccs);
    }

    /**
    * @description Determine and set the Parents of the Accounts based on the Parent NCES ID value, if its changed
    * @param accList List of Accounts to determine the parents for
    * @param oldMap Map with previous values of given Accounts
    */
    public static void setParentAccountsOnUpdate(List<Account> accList, Map<Id, Account> oldMap) {
        List<String> parentNcesIds = new List<String>();
        List<Account> filteredAccs = new List<Account>();
        for (Account acc: accList) {
            // Only accounts with populated Parent NCES ID values should be processed
            if (acc.ParentNcesId__c != null) {
                // Account oldAcc = oldMap.get(acc.Id);
                // if (acc.ParentNcesId__c != oldAcc.ParentNcesId__c || acc.ParentAccountTEST__c != oldAcc.ParentAccountTEST__c) {
                    filteredAccs.add(acc);
                    parentNcesIds.add(acc.ParentNcesId__c);
                // }
            }
		}
        // Retrieve the Parent Accounts using collected NCES IDs and set the parent lookup value
        populateParentAccountId(parentNcesIds, filteredAccs);
    }

    /**
    * @description Set the Parent Account lookup on given Accounts using the collected NCES ID values
    * @param parentNcesIds List of NCES ID values collected from the Accounts
    * @param filteredAccs List of Account records to populate the parents of
    */
    private static void populateParentAccountId(List<String> parentNcesIds, List<Account> filteredAccs) {
        ParentAccountAssignmentSetting__mdt setting = [SELECT Id, ParentField__c, KeepExistingParentAccounts__c FROM ParentAccountAssignmentSetting__mdt LIMIT 1];
        // Retrieve the parent accounts using the provided NCES IDs and map the Account IDs against NCES IDs
        List<Account> parentAccounts = [SELECT Id, ncesleaid__c, ParentId, ParentAccountTEST__c FROM Account WHERE ncesleaid__c IN :parentNcesIds];
		Map<String, Id> parentMap = new Map<String, Id>();
        for (Account acc: parentAccounts) {
            parentMap.put(acc.ncesleaid__c, acc.Id);
        }
        System.debug('parentMap'+parentMap);
		// Set the Parent Account lookup if matching Account was found
        for (Account acc: filteredAccs) {
            Id parentId = parentMap.get(acc.ParentNcesId__c);
            Id oldParentId = (Id)acc.get(setting.ParentField__c);
            if (acc.ParentNcesId__c != null && !(setting.KeepExistingParentAccounts__c == true && oldParentId != null)) {
	            acc.put(setting.ParentField__c, parentId);
            }
        }
    }
}