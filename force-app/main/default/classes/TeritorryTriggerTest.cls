@isTest
public class TeritorryTriggerTest {
    
    @isTest
    public static void m1()
    {
        Account acc = new Account();
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'School'].Id;
        acc.Name = 'testing';
        acc.ShippingPostalCode = '12345';
        acc.ncessch__c = '00001';
        acc.Status__c = 'Active';
        acc.No_NCES_Data__c = 'Not Found';
        insert acc;
        
        Territory_ID__c  territory = new Territory_ID__c();
        territory.City__c = 'test';
        territory.County__c = 'test';
        territory.Name = 'qwerty';
        territory.Zip_Code__c = '12345';
        territory.County__c = 'wqerty';
        insert territory;
    }
}