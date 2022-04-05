@isTest
public class LeadTriggerTest {

    private static final String TEST_TERRITORY_NUMBER = '99';
    private static final String TEST_TERRITORY_ZIP = '12345';

    @testSetup
    private static void setup(){
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
    public static void assignByZipCodeSuccess() {
        Test.startTest();
            Lead l = new Lead();
            l.FirstName = 'Test';
            l.LastName = 'Lead';
            l.PostalCode = TEST_TERRITORY_ZIP;
       		l.Company = 'Test Company';
            insert l;
        Test.stopTest();

        TerritoryName__c amPosition = [SELECT Id, Name__c FROM TerritoryName__c WHERE Name = 'John Johnson' LIMIT 1];
        TerritoryName__c pcPosition = [SELECT Id, Name__c FROM TerritoryName__c WHERE Name = 'Jack Jackson' LIMIT 1];
        TerritoryName__c rvpPosition = [SELECT Id, Name__c FROM TerritoryName__c WHERE Name = 'Steven Stevenson' LIMIT 1];
        Lead updatedLead = [SELECT Territory_ID__c, Territory_Name__c, AM__c, RVP__c, PC__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals(TEST_TERRITORY_NUMBER, updatedLead.Territory_ID__c);
        System.assertEquals(amPosition.Id, updatedLead.Territory_Name__c);
        System.assertEquals(amPosition.Name__c, updatedLead.AM__c);
        System.assertEquals(pcPosition.Name__c, updatedLead.PC__c);
        System.assertEquals(rvpPosition.Name__c, updatedLead.RVP__c);
    }
}