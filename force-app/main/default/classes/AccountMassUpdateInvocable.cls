public class AccountMassUpdateInvocable {
    
    public class Input {
        @InvocableVariable(label='Concatenated Zip Codes' description='List of Zip Codes concatenated with a semicolon.' required='false')
        public String concatZipCodes;
        @InvocableVariable(label='Batch Size' description='Amount of Accounts to update in each batch. Values below 0 and above 200 are ignored and set to default instead.' required='false')
        public Integer batchSize;
        @InvocableVariable(label='Concatenated States' description='List of States concatenated with a semicolon.' required='false')
        public String concatStates;
        @InvocableVariable(label='Concatenated MSA' description='List of Counties concatenated with a semicolon.' required='false')
        public String concatCounties;
        @InvocableVariable(label='Concatenated MSA' description='List of Counties concatenated with a semicolon.' required='false')
        public String concatMSA;
        @InvocableVariable(label='Territory Name Id' description='The record Id of the Territory Name' required='false')
        public String territoryNameId;
        
        public Input() {}
    }
    
    @InvocableMethod(label='Recalculate Territory Details' category='Territory_ID__c')
    public static List<Id> scheduleBatchableJob(List<Input> inputs) {
        Set<String> zipCodeSet = new Set<String>();
        Set<String> stateSet = new Set<String>();
        Set<String> countySet = new Set<String>();
        Set<String> msaSet = new Set<String>();
        string tnId;
        string context;
        // Loop through all inputs and collect all zipcode values
        for (Input i: inputs) {
            tnId = i.TerritoryNameId;
            if (!String.isBlank(i.concatZipCodes)) {
                List<String> zipCodeList = i.concatZipCodes.split(';');            
                for (String zip: zipCodeList) {
                    zipCodeSet.add(zip.trim());
                }
                context = 'zip';
            } else if(!String.isBlank(i.concatStates)) {
                List<String> stateList = i.concatStates.split(';');            
                for (String state: stateList) {
                    stateSet.add(state.trim());
                }
                context = 'state';
            } else if(!String.isBlank(i.concatCounties)) {
                List<String> countyList = i.concatCounties.split(';');            
                for (String county: countyList) {
                    countySet.add(county.trim());
                }
                context = 'county';
            } else if(!String.isBlank(i.concatMSA)) {
                List<String> msaList = i.concatMSA.split(';');            
                for (String msa: msaList) {
                    msaSet.add(msa.trim());
                }
                context = 'msa';
            }
        }
        AccountTerritoryRecalcBatchable batchable = new AccountTerritoryRecalcBatchable(zipCodeSet);
        Integer batchSize = inputs[0].batchSize;
        // Fallback to default if provided batch size is lower than 0 or higher than 200
        if (batchSize != null && batchSize <= 200 && 0 < batchSize) {
            return buildReturnList(inputs.size(), Database.executeBatch(batchable, batchSize));
        } else {
            return buildReturnList(inputs.size(), Database.executeBatch(batchable));
        }
    }
    
    private static List<Id> buildReturnList(Integer size, Id jobId) {
        List<Id> idList = new List<Id>();
        for (Integer i = 0; i < size; i++) {
            idList.add(jobId);
        }
        return idList;
    }
}