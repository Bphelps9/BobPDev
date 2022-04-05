@isTest
public class TerritoryID_t {
    
    //Test to ensure that if the Territory Name related to the TerritoryID record is changed, then the 
    //Accounts, Account Teams, Contacts, and Opps are updated for the new Territory Assignments
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
        territories[0].Territory_Name__c = territorynames[1].Id;
        update territories;
        Test.stopTest();
        
    }

}