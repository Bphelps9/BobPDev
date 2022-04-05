@isTest
public class EventTriggerTest {

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
            Event e1 = generateEvent(acc.Id, con.Id);
            Event e2 = generateEvent(opp.Id, null);
            insert new List<Event> {e1, e2};
        Test.stopTest();
        
        Event insertedE1 = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Event WHERE Id = :e1.Id];
        System.assertEquals(acc.Id, insertedE1.Account__c);
        System.assertEquals(null, insertedE1.Opportunity__c);
        System.assertEquals(con.Id, insertedE1.Contact__c);
        Event insertedE2 = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Event WHERE Id = :e2.Id];
        System.assertEquals(null, insertedE2.Account__c);
        System.assertEquals(opp.Id, insertedE2.Opportunity__c);
        System.assertEquals(null, insertedE2.Contact__c);
    }
    
    @isTest
    public static void beforeUpdateTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Event e = generateEvent(acc.Id, con.Id);
        insert e;
        Event insertedE = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Event WHERE Id = :e.Id];
        System.assertEquals(acc.Id, insertedE.Account__c);
        System.assertEquals(null, insertedE.Opportunity__c);
        System.assertEquals(con.Id, insertedE.Contact__c);
        
        Test.startTest();
			e.WhatId = opp.Id;
        	e.WhoId = null;
            update e;
        Test.stopTest();
        
        Event updatedE = [SELECT Id, Account__c, Opportunity__c, Contact__c FROM Event WHERE Id = :e.Id];
        System.assertEquals(null, updatedE.Account__c);
        System.assertEquals(opp.Id, updatedE.Opportunity__c);
        System.assertEquals(null, updatedE.Contact__c);
    }
    
    private static Event generateEvent(Id whatId, Id whoId) {
        Event e = new Event();
        e.Subject = 'Test Event';
        e.WhatId = whatId;
        e.WhoId = whoId;
        e.DurationInMinutes = 10;
        e.ActivityDateTime = System.now().addHours(10);
        return e;
    }
}