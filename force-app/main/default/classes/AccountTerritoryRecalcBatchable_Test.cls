@isTest
public class AccountTerritoryRecalcBatchable_Test {

    private static final String TEST_TERRITORY_NUMBER = '99';
    private static final String TEST_TERRITORY_ZIP = '12345';

    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'School'].Id;
        acc.Status__c = 'Active';
        acc.ncessch__c = '00001';
        acc.ShippingPostalCode = TEST_TERRITORY_ZIP;
		acc.No_NCES_Data__c = 'Not Found';
		AccountTriggerHandler.bypassTrigger = true;
        insert acc;

        Territory_ID__c testTerritory = new Territory_ID__c();
        testTerritory.Name = TEST_TERRITORY_NUMBER;
        testTerritory.Zip_Code__c = TEST_TERRITORY_ZIP;
        testTerritory.City__c = 'test';
        testTerritory.County__c = 'test';
        insert testTerritory;

        TerritoryName__c amPosition = new TerritoryName__c();
        amPosition.Territory_ID__c = TEST_TERRITORY_NUMBER;
        amPosition.Position__c = 'John Johnson - Account Manager';
        amPosition.Name = 'John Johnson';
        insert amPosition;

        TerritoryName__c pcPosition = new TerritoryName__c();
        pcPosition.Territory_ID__c = TEST_TERRITORY_NUMBER;
        pcPosition.Position__c = 'Jack Jackson - Program Consultant';
        pcPosition.Name = 'Jack Jackson';
        insert pcPosition;

        TerritoryName__c rvpPosition = new TerritoryName__c();
        rvpPosition.Territory_ID__c = TEST_TERRITORY_NUMBER;
        rvpPosition.Position__c = 'Steven Stevenson - Regional VP';
        rvpPosition.Name = 'Steven Stevenson';
        insert rvpPosition;
    }
    
    @isTest
    public static void recalculateTerritorySuccess() {
        Territory_ID__c ter = [SELECT Id, Name, Zip_Code__c FROM Territory_ID__c LIMIT 1];
        Account acc = [SELECT Id, Territory_Name__c, Territory_ID__c, AM__c, PC__c, RVP__c, ShippingPostalCode FROM Account LIMIT 1];
        Set<String> zipCodeSet = new Set<String>();
        zipCodeSet.add(acc.ShippingPostalCode);
        
        // All territory details should be empty on the account before recalculation
        System.assertEquals(null, acc.Territory_ID__c);
        System.assertEquals(null, acc.Territory_Name__c);
        System.assertEquals(null, acc.AM__c);
        System.assertEquals(null, acc.PC__c);
        System.assertEquals(null, acc.RVP__c);
        Test.startTest();
        	// Start recalculation
            AccountTerritoryRecalcBatchable batchable = new AccountTerritoryRecalcBatchable(zipCodeSet);
            Id jobId = Database.executeBatch(batchable);
        Test.stopTest();
        // All territory details should be updated on the account
        Account updatedAccount = [SELECT Id, Territory_Name__c, Territory_ID__c, AM__c, PC__c, RVP__c, ShippingPostalCode FROM Account WHERE Id = :acc.Id];
        TerritoryName__c amPosition = [SELECT Id, Name__c FROM TerritoryName__c WHERE Name = 'John Johnson' LIMIT 1];
        TerritoryName__c pcPosition = [SELECT Id, Name__c FROM TerritoryName__c WHERE Name = 'Jack Jackson' LIMIT 1];
        TerritoryName__c rvpPosition = [SELECT Id, Name__c FROM TerritoryName__c WHERE Name = 'Steven Stevenson' LIMIT 1];
        System.assertEquals(TEST_TERRITORY_NUMBER, updatedAccount.Territory_ID__c);
        System.assertEquals(amPosition.Id, updatedAccount.Territory_Name__c);
        System.assertEquals(amPosition.Name__c, updatedAccount.AM__c);
        System.assertEquals(pcPosition.Name__c, updatedAccount.PC__c);
        System.assertEquals(rvpPosition.Name__c, updatedAccount.RVP__c);

        // Count the amount of logs generated
        Integer finishCount = [SELECT count() FROM Log__c WHERE Status__c = 'Finished' AND Job_ID__c = :jobId];
        System.assertEquals(1, finishCount);
        Integer errorCount = [SELECT count() FROM Log__c WHERE Status__c = 'Account Batch Error' AND Job_ID__c = :jobId];
        System.assertEquals(0, errorCount);
    }
    
    @isTest
    public static void recalculateTerritoryError() {
        Territory_ID__c ter = [SELECT Id, Name, Zip_Code__c FROM Territory_ID__c LIMIT 1];
        Account acc = [SELECT Id, ShippingStreet, ShippingPostalCode FROM Account LIMIT 1];
        Set<String> zipCodeSet = new Set<String>();
        zipCodeSet.add(acc.ShippingPostalCode);
        
        Test.startTest();
        	// Inject a value to automatically insert error logs on every updated account
            AccountTerritoryRecalcBatchable.INSERT_ERROR_LOG = true;
            AccountTerritoryRecalcBatchable batchable = new AccountTerritoryRecalcBatchable(zipCodeSet);
            Id jobId = Database.executeBatch(batchable);
        Test.stopTest();
        // Count the amount of erros inserted
        Integer errorCount = [SELECT count() FROM Log__c WHERE Status__c = 'Account Batch Error' AND Job_ID__c = :jobId];
        System.assertEquals(1, errorCount);
    }
}