@isTest
public class TaskTriggerTest {

    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.No_NCES_Data__c = 'Not Found';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Closed - Won';
        opp.CloseDate = System.today();
        opp.Interest_Source__c = 'Advisory board';
        insert opp;
            
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
    }
    
    @isTest
    public static void beforeInsertTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            Task t1 = generateTask(acc.Id, con.Id);
            Task t2 = generateTask(opp.Id, null);
            insert new List<Task> {t1, t2};
        Test.stopTest();
        
        Task insertedT1 = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Task WHERE Id = :t1.Id];
        System.assertEquals(acc.Id, insertedT1.Account__c);
        System.assertEquals(null, insertedT1.Opportunity__c);
        System.assertEquals(con.Id, insertedT1.Contact__c);
        Task insertedT2 = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Task WHERE Id = :t2.Id];
        System.assertEquals(null, insertedT2.Account__c);
        System.assertEquals(opp.Id, insertedT2.Opportunity__c);
        System.assertEquals(null, insertedT2.Contact__c);
    }
    
    @isTest
    public static void beforeUpdateTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Task t = generateTask(acc.Id, con.Id);
        insert t;
        Task insertedT = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Task WHERE Id = :t.Id];
        System.assertEquals(acc.Id, insertedT.Account__c);
        System.assertEquals(null, insertedT.Opportunity__c);
        System.assertEquals(con.Id, insertedT.Contact__c);
        
        Test.startTest();
			t.WhatId = opp.Id;
        	t.WhoId = null;
            update t;
        Test.stopTest();
        
        Task updatedT = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Task WHERE Id = :t.Id];
        System.assertEquals(null, updatedT.Account__c);
        System.assertEquals(opp.Id, updatedT.Opportunity__c);
        System.assertEquals(null, updatedT.Contact__c);
    }
    
    private static Task generateTask(Id whatId, Id whoId) {
        Task t = new Task();
        t.Subject = 'Test Task';
        t.WhatId = whatId;
        t.WhoId = whoId;
        return t;
    }
}