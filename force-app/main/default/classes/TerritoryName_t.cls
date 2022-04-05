@isTest
public class TerritoryName_t {
//test class for the TerritoryName__c object
        
    //test to ensure that if the AM on the Territory Name object is changed then
    //all the Accounts, Contacts and Opps assocaited with the Territory Name 
    //should change their owners to the new AM.
    @isTest
    public static void afterupdateuser(){
        Set<String> usernames = Utility.generateusernames(3);
        List<User> users = TestFactory.CreateUser(usernames);
        List<TerritoryName__c> territorynames = TestFactory.createTerritoryNames(5, users);
        List<String> zipcodes = Utility.generatezipcodes(5);
        List<Territory_ID__c> territories = TestFactory.createTerritories(zipCodes, territorynames);
        List<Account> accts = TestFactory.createSchoolAccounts(zipcodes);
        List<Contact> contacts = TestFactory.createContacts(accts);
        List<Opportunity> opps = TestFactory.createOpportunities(accts);
        
        Test.startTest();
        territorynames[0].User__c = users[1].Id;
        update territorynames;
        Test.stopTest();
        //because this calls an asynchronous batch jobs can't do asserts
    }
    
    //test to ensure that if the PC or the RVP are changed on a Territory Name, then the associated
    //Accounts have their Account Teams inserted as well
    @isTest
    public static void afterupdateteaminsert(){
        Set<String> usernames = Utility.generateusernames(3);
        List<User> users = TestFactory.CreateUser(usernames);
        List<TerritoryName__c> territorynames = TestFactory.createTerritoryNames(5, users);
        List<String> zipcodes = Utility.generatezipcodes(5);
        List<Territory_ID__c> territories = TestFactory.createTerritories(zipCodes, territorynames);
        List<Account> accts = TestFactory.createSchoolAccounts(zipcodes);
        List<Contact> contacts = TestFactory.createContacts(accts);
        List<Opportunity> opps = TestFactory.createOpportunities(accts);
        
        Test.startTest();
        territorynames[0].Program_Consultant__c = users[0].Id;
        territorynames[0].Regional_VP__c = users[1].Id;
        update territorynames;
        Test.stopTest();
        //because this calls an asynchronous batch jobs can't do asserts
        
    }
    
        //test to ensure that if the PC or the RVP are changed on a Territory Name, then the associated
    //Accounts have their Account Teams updated as well
        @isTest
    public static void afterupdateteamupdate(){
        Set<String> usernames = Utility.generateusernames(3);
        List<User> users = TestFactory.CreateUser(usernames);
        Map<String, String> userRoleMap = new Map<String, String>(); 
        userRoleMap.put(users[1].Id, 'Program Consultant');
        userRoleMap.put(users[2].Id, 'Regional VP');
        List<TerritoryName__c> territorynames = TestFactory.createTerritoryNames(5, users);
        List<String> zipcodes = Utility.generatezipcodes(5);
        List<Territory_ID__c> territories = TestFactory.createTerritories(zipCodes, territorynames);
        List<Account> accts = TestFactory.createSchoolAccounts(zipcodes);
        List<AccountTeamMember> atms = TestFactory.createAccountTeamMembers(accts[0].Id, userRoleMap);
        List<Contact> contacts = TestFactory.createContacts(accts);
        List<Opportunity> opps = TestFactory.createOpportunities(accts);
        
        Test.startTest();
        territorynames[0].Program_Consultant__c = users[0].Id;
        territorynames[0].Regional_VP__c = users[1].Id;
        update territorynames;
        Test.stopTest();
        
    }
}