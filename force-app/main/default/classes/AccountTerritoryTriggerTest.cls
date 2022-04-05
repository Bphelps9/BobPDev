@isTest
public class AccountTerritoryTriggerTest {

    @isTest
    public static void m1()
    {
        Territory_ID__c  territory = new Territory_ID__c();
        territory.City__c = 'test';
        territory.County__c = 'test';
        territory.Name = 'qwerty';
        territory.Zip_Code__c = '12345';
        territory.County__c = 'wqerty';
        insert territory;
        
        Account acc1 = new Account(Name='parent 1',ParentNcesId__c='12345678');
        Account acc2 = new Account(Name='parent2',ParentNcesId__c='123456789');
        
        Account acc = new Account();
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'School'].Id;
        acc.Name = 'testing';
        acc.ShippingPostalCode = '12345';
        acc.ncessch__c = '000001';
        acc.Status__c = 'Active';
		acc.No_NCES_Data__c = 'Not Found';
        acc.ParentNcesId__c='12345678';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Target';
        opp.Confidence_Level__c = 'Yes';
        opp.CloseDate = Date.today();
        opp.AccountId = acc.id;
        opp.Ship_To__c = acc.Id;
        opp.Bill_To__c = acc.Id;
        opp.Destination__c = acc.Id;
        opp.Interest_Source__c = 'Advisory board';
        insert opp;
        
        Case cs = new Case();cs.AccountId = acc.Id;
        //insert cs;
        
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'tests';
        con.email = 'test@gmail.com';
        con.AccountId = acc.id;
        insert con;
        
        Task tsk = new Task();
        tsk.WhatId = acc.Id;
        tsk.Subject = 'Call';
        insert tsk;
        
        Event et = new Event();
        et.WhatId = acc.Id;
        et.DurationInMinutes = 120;
        et.ActivityDateTime = DateTime.now();
        et.Subject = 'Meeting';
        insert et;
        
        acc.ParentNcesId__c='123456789';
        acc.name= 'test';
        update acc;
    }
}