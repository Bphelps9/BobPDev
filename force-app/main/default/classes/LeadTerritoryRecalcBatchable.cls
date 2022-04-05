public class LeadTerritoryRecalcBatchable implements Database.Batchable<SObject> {

    @TestVisible
    private static Boolean INSERT_ERROR_LOG = false;
    private final Set<String> zipCodeSet = new Set<String>();

    public LeadTerritoryRecalcBatchable(Set<String> zipCodes) {
        if (zipCodes != null && !zipCodes.isEmpty()) {
            this.zipCodeSet.addAll(zipCodes);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Retrieve the leads that are not manually overriden
        String query = 'SELECT Id, PostalCode, Territory_ID__c, OwnerId FROM Lead';
        // If Zip Codes are provided then the query should have a criteria, otherwise all leads should be retrieved
        System.debug(zipCodeSet);
        System.debug(zipCodeSet.size());
        System.debug(zipCodeSet.isEmpty());
        if (!this.zipCodeSet.isEmpty()) {
            query += ' WHERE PostalCode IN (\'' + String.join(new List<String>(this.zipCodeSet), '\',\'') + '\')';
        }
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        // Assign the territories using the same method used in Lead Trigger
        LeadTriggerHandler.assignCustomTerritories(scope);
        // Bypass lead trigger handler to reduce the processing time
        LeadTriggerHandler.bypassTrigger = true;
        List<Database.SaveResult> results = Database.update(scope, false);
        // Collect and store all DML errors as logs
        List<Log__c> errorLogs = new List<Log__c>();
        for (Database.SaveResult result: results) {
            if (!result.isSuccess() || INSERT_ERROR_LOG) {
                Log__c log = new Log__c();
                log.Job_ID__c = BC.getJobId();
                log.Status__c = 'Lead Batch Error';
                for (Database.Error err: result.getErrors()) {
                    log.Description__c += err.getMessage() + '\n';
                }
		        errorLogs.add(log);
            }
        }
        if (!errorLogs.isEmpty()) {
            Database.insert(errorLogs, false);
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Insert a log with details of the batchable job after it finishes running
        Log__c log = new Log__c();
        log.Job_ID__c = BC.getJobId();
        log.Status__c = 'Finished';
        log.Description__c = 'Lead batchable job finished running';
        Database.insert(log, false);
    }   
}