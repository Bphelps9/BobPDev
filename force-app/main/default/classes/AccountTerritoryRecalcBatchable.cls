/**
 * @description Update the territory details of Accounts with given Zip Codes
 */
public class AccountTerritoryRecalcBatchable implements Database.Batchable<SObject> {

    @TestVisible
    private static Boolean INSERT_ERROR_LOG = false;
    private final Set<String> zipCodeSet = new Set<String>();

    public AccountTerritoryRecalcBatchable(Set<String> zipCodes) {
        if (zipCodes != null && !zipCodes.isEmpty()) {
            this.zipCodeSet.addAll(zipCodes);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Retrieve the accounts that are not manually overriden
        String query = 'SELECT Id, ShippingPostalCode, Special_Territory_Assignment__c, TerritoryOverride__c, Territory_ID__c, OwnerId FROM Account WHERE TerritoryOverride__c != \'Manual Input\'';
        // If Zip Codes are provided then the query should have a criteria, otherwise all accounts should be retrieved
        if (!zipCodeSet.isEmpty()) {
            query += ' AND ShippingPostalCode IN (\'' + String.join(new List<String>(this.zipCodeSet), '\',\'') + '\')';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        // Assign the territories using the same method used in Account Trigger
        List<Account> accList = AccountTriggerHandler.assignCustomTerritories(scope);
        // Bypass account trigger handler to reduce the processing time
        AccountTriggerHandler.bypassTrigger = true;
        List<Database.SaveResult> results = Database.update(accList, false);
        // Collect and store all DML errors as logs
        List<Log__c> errorLogs = new List<Log__c>();
        for (Database.SaveResult result: results) {
            if (!result.isSuccess() || INSERT_ERROR_LOG) {
                Log__c log = new Log__c();
                log.Job_ID__c = BC.getJobId();
                log.Status__c = 'Account Batch Error';
                for (Database.Error err: result.getErrors()) {
                    log.Description__c += err.getMessage() + '\n';
                }
		        errorLogs.add(log);
            }
        }
        if (!errorLogs.isEmpty()) {
            Database.insert(errorLogs, true);
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Insert a log with details of the batchable job after it finishes running
        Log__c log = new Log__c();
        log.Job_ID__c = BC.getJobId();
        log.Status__c = 'Finished';
        log.Description__c = 'Account batchable job finished running';
        Database.insert(log, false);
    }
}