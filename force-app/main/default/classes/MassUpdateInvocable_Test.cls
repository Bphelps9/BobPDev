@isTest
public class MassUpdateInvocable_Test {

    @isTest
    static void scheduleBatchableJobSuccess() {
		MassUpdateInvocable.Input inp = new MassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        inp.batchSize = 150;
        inp.objectName = 'Account';
        Test.startTest();
            List<MassUpdateInvocable.Input> inputList = new List<MassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = MassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds];
        System.assertEquals(1, jobCount);
    }
    
    @isTest
    static void scheduleBatchableJobEmptyZipCodes() {
		MassUpdateInvocable.Input inp = new MassUpdateInvocable.Input();
        // Pass empty zip code string
        inp.concatZipCodes = '';
        inp.batchSize = 150;
        inp.objectName = 'Account';
        Test.startTest();
            List<MassUpdateInvocable.Input> inputList = new List<MassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = MassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds];
        System.assertEquals(1, jobCount);
    }
    
    @isTest
    static void scheduleBatchableJobBatchSizeOutOfBounds() {
		MassUpdateInvocable.Input inp = new MassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        // Set the batch size higher than 200 to force running batchable class with default batch size
        inp.batchSize = 250;
        inp.objectName = 'Account';
        Test.startTest();
            List<MassUpdateInvocable.Input> inputList = new List<MassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = MassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds];
        System.assertEquals(1, jobCount);
    }

    @isTest
    static void scheduleBatchableJobAccountObject() {
		MassUpdateInvocable.Input inp = new MassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        inp.batchSize = 200;
        // Execute this job for Account records and ensure the corresponding batchable job has run
        inp.objectName = 'Account';
        Test.startTest();
            List<MassUpdateInvocable.Input> inputList = new List<MassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = MassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        String accountClassName = AccountTerritoryRecalcBatchable.class.getName();
        Id accountClassId = [SELECT Id FROM ApexClass WHERE Name = :accountClassName LIMIT 1].Id;
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds AND ApexClassId = :accountClassId];
        System.assertEquals(1, jobCount);
    }
    
    @isTest
    static void scheduleBatchableJobLeadObject() {
		MassUpdateInvocable.Input inp = new MassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        inp.batchSize = 200;
        // Execute this job for Lead records and ensure the corresponding batchable job has run
        inp.objectName = 'Lead';
        Test.startTest();
            List<MassUpdateInvocable.Input> inputList = new List<MassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = MassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        String leadClassName = LeadTerritoryRecalcBatchable.class.getName();
        Id leadClassId = [SELECT Id FROM ApexClass WHERE Name = :leadClassName LIMIT 1].Id;
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds AND ApexClassId = :leadClassId];
        System.assertEquals(1, jobCount);
    }
    
    @isTest
    static void scheduleBatchableJobUnsupportedObject() {
		MassUpdateInvocable.Input inp = new MassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        inp.batchSize = 200;
        // Execute this job for an unsupported object type. Batchable job will not run and class will return null for Job ID
        inp.objectName = 'Opportunity';
        Test.startTest();
            List<MassUpdateInvocable.Input> inputList = new List<MassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = MassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        System.assertEquals(null, jobIds[0]);
    }
}