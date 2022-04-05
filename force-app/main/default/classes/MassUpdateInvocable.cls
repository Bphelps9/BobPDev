public class MassUpdateInvocable {

    public class Input {
        @InvocableVariable(label='Concatenated Zip Codes' description='List of Zip Codes concatenated with a semicolon. If no value is provided all records are updated.' required='false')
        public String concatZipCodes;
        @InvocableVariable(label='Batch Size' description='Amount of records to update in each batch. Values below 0 and above 200 are ignored and set to default instead.' required='false')
        public Integer batchSize;
        @InvocableVariable(label='Object Type' description='Name of the object that is processed' required='false')
		public String objectName;
        
        public Input() {}
    }

    @InvocableMethod(label='Recalculate Territory Details')
    public static List<Id> scheduleBatchableJob(List<Input> inputs) {
        List<Id> returnList = new List<Id>();
        // Loop through all inputs and collect zipcode values into sets
        for (Input i: inputs) {
	        Set<String> zipCodeSet = new Set<String>();
            if (!String.isBlank(i.concatZipCodes)) {
            	List<String> zipCodeList = i.concatZipCodes.split(';');            
                for (String zip: zipCodeList) {
                    zipCodeSet.add(zip.trim());
                }
                if (i.batchSize == null || i.batchSize > 200 || i.batchSize < 0) {
                    i.batchSize = 200;
                }
            }
            if (i.objectName == 'Account') {
	            AccountTerritoryRecalcBatchable batchable = new AccountTerritoryRecalcBatchable(zipCodeSet);
                Id jobId = Database.executeBatch(batchable, i.batchSize);
                returnList.add(jobId);
            } else if (i.objectName == 'Lead') {
	            LeadTerritoryRecalcBatchable batchable = new LeadTerritoryRecalcBatchable(zipCodeSet);
                Id jobId = Database.executeBatch(batchable, i.batchSize);
                returnList.add(jobId);
            } else {
                returnList.add(null);
            }
        }
        return returnList;
    }
}