public class OpportunitiesUpdateBatch implements Database.Batchable<Sobject> {
    /* Author: Bob Phelps
     *
     *  Date Created: 03/28/2021
     *
     *  Purpose: Batch process to bulk update Opportunities
     *
     *  Notes:
     *
     *  Modification History:
     *  Date / Author  / Description
     *  -------------  ------------------  --------------------------------------------------------------------------------------------------------------
     * */

Set<Id> territoryNameIds;
    String amId;
    public OpportunitiesUpdateBatch(Set<Id> TNIds, String ownerid) {
        this.territoryNameIds = TNIds;
        this.amId = ownerid;
    }
    //get the list of opportunities
    public Database.QueryLocator start(Database.BatchableContext BC) {
         // collect the opportunities to be processed. this query ONLY collects those whose owners do NOT match
        // the new owner id being passed to the batch
        String query = 'Select Id, OwnerId from Opportunity where Account.Related_TerritoryID__r.Territory_Name__r.Id in: territoryNameIds and OwnerId != :amId and StageName != \'Closed Won\'';
        return Database.getQueryLocator(query);
    }
    //perform the update
    public void execute(Database.BatchableContext BC, List<Opportunity> opps) {
        if(Utility.isNullorEmpty(opps) == false){
        for (Opportunity opp : opps) {
            opp.OwnerId = amId;
        }
        DMLOperations dmlupdate = new DMLOperations(opps, 'update');
    }
    }

    //send the user an email with the batch results
    public void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ a.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Opportunity Owners Updated ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems + 'with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}