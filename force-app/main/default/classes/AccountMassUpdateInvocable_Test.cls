@isTest
public class AccountMassUpdateInvocable_Test {

    @isTest
    static void scheduleBatchableJobSuccess() {
		AccountMassUpdateInvocable.Input inp = new AccountMassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        inp.batchSize = 150;
        Test.startTest();
            List<AccountMassUpdateInvocable.Input> inputList = new List<AccountMassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = AccountMassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds];
        System.assertEquals(1, jobCount);
    }
    
    @isTest
    static void scheduleBatchableJobEmptyZipCodes() {
		AccountMassUpdateInvocable.Input inp = new AccountMassUpdateInvocable.Input();
        // Pass empty zip code string
        inp.concatZipCodes = '';
        inp.batchSize = 150;
        Test.startTest();
            List<AccountMassUpdateInvocable.Input> inputList = new List<AccountMassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = AccountMassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds];
        System.assertEquals(1, jobCount);
    }
    
    @isTest
    static void scheduleBatchableJobBatchSizeOutOfBounds() {
		AccountMassUpdateInvocable.Input inp = new AccountMassUpdateInvocable.Input();
        inp.concatZipCodes = '95732;14563';
        // Set the batch size higher than 200 to force running batchable class with default batch size
        inp.batchSize = 250;
        Test.startTest();
            List<AccountMassUpdateInvocable.Input> inputList = new List<AccountMassUpdateInvocable.Input>();
            inputList.add(inp);
            List<Id> jobIds = AccountMassUpdateInvocable.scheduleBatchableJob(inputList);
		Test.stopTest();
        
        Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE Id IN :jobIds];
        System.assertEquals(1, jobCount);
    }
}