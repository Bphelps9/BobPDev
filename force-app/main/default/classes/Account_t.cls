@isTest
public class Account_t {
    
    //tests the Territory Assignment method of the wrapper when a new account is inserted
    @isTest
    public static void beforeinsert(){
        Set<String> usernames = Utility.generateusernames(3);
        List<User> users = TestFactory.CreateUser(usernames);
        List<TerritoryName__c> territorynames = TestFactory.createTerritoryNames(5, users);
        List<String> zipcodes = Utility.generatezipcodes(5);
        List<Territory_ID__c> territories = TestFactory.createTerritories(zipCodes, territorynames);
        
        Test.startTest();
        List<Account> accts = TestFactory.createSchoolAccounts(zipcodes);
        Test.stopTest();
        
        List<Account> postAccounts = new List<Account>([Select Id, Related_TerritoryID__c, Related_TerritoryID__r.Zip_Code__c, Related_TerritoryID__r.Territory_Name__r.User__r.username, ShippingPostalCode, Owner.username from Account where Related_TerritoryID__c != null]);
        system.assertEquals(accts.size(), postAccounts.size());
        system.assertEquals(postAccounts[0].Owner.username, postAccounts[0].Related_TerritoryID__r.Territory_Name__r.User__r.username);
        system.assertEquals(postAccounts[0].ShippingPostalCode, postAccounts[0].Related_TerritoryID__r.Zip_Code__c);
        system.debug('the postAccounts size is ' + postAccounts.size());
        system.debug('thepostAccount Owner is ' + postAccounts[0].Owner.username + ' and the AM on the Territory is ' + postAccounts[0].Related_TerritoryID__r.Territory_Name__r.User__r.username);
    }
    
    //tests when the account is updated and either the zip code changes or the override changes
    @isTest
    public static void afterupdate(){
        Set<String> usernames = Utility.generateusernames(3);
        List<User> users = TestFactory.CreateUser(usernames);
        List<TerritoryName__c> territorynames = TestFactory.createTerritoryNames(5, users);
        List<String> zipcodes = Utility.generatezipcodes(5);
        List<Territory_ID__c> territories = TestFactory.createTerritories(zipCodes, territorynames);
        List<Account> accts = TestFactory.createSchoolAccounts(zipcodes);
        List<Contact> contacts = TestFactory.createContacts(accts);
        List<Opportunity> opps = TestFactory.createOpportunities(accts);
        
        Test.startTest();
        accts[0].ShippingPostalCode = zipcodes[1];
        update accts;
        Test.stopTest();
        
    }
    
}