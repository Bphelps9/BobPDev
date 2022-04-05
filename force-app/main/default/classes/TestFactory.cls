@isTest
public class TestFactory {
    
    //-----------------------------BOB PHELPS CREATED TEST METHODS--------------------------------------
        public static List<Account> createSchoolAccounts(List<String> zipCodes) {
        List<Account> accts = new List<Account>();
        For(String zipCode : zipcodes){
            Account acc = new Account();
            acc.RecordTypeId = ACCOUNT_SCHOOL_RT_ID;
            acc.Name = 'Test School Account';
            acc.ShippingCountry = 'US';
            acc.ShippingPostalCode = zipCode;
            acc.ncessch__c = zipCode;
            acc.Status__c = 'Active';
            acc.No_NCES_Data__c = 'Not Found';
            accts.add(acc);
        }
        //insert accts;
        DMLOperations dmlinsert = new DMLOperations(accts, 'insert');
        return accts;
    }
    
    public static List<AccountTeamMember> createAccountTeamMembers(Id acctId, Map<String, String> userRoleMap){
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        for(String user : userRoleMap.keySet()){
            AccountTeamMember atm = new AccountTeamMember(AccountId = acctId, UserId = user, TeamMemberRole = userRoleMap.get(user));
            atms.add(atm);
        }
        DMLOperations dmlinsert = new DMLOperations(atms, 'insert');
        return atms;
    }
    
        public static List<Opportunity> createOpportunities(List<Account> accounts) {
        List<Opportunity> opps = new List<Opportunity>();
        for(Account account : accounts){
            Opportunity opp = new Opportunity();
            opp.AccountId = account.Id;
            opp.Name = 'Test Opportunity';
            opp.RecordTypeId = OPPORTUNITY_SALES_RT_ID;
            opp.IsExcludedFromTerritory2Filter = true;
            opp.StageName = 'Target';
            opp.Confidence_Level__c = 'yes';
            opp.CloseDate = System.today().addMonths(1);
            opp.Interest_Source__c = 'Advisory board';
            opps.add(opp);
        }
        DMLOperations dmlinsert = new DMLOperations(opps, 'insert');
        return opps;
    }
    
        public static List<Contact> createContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        for(Account account : accounts){
            Contact con = new Contact();
            con.AccountId = account.Id;
            con.LastName = 'Test Contact';
            con.Title = 'Director';
            contacts.add(con);      
        }
        DMLOperations dmlinsert = new DMLOperations(contacts, 'insert');
        return contacts;
    }
    
    public static List<Territory_ID__c> createTerritories(List<String> zipCodes, List<TerritoryName__c> territorynames) {
        List<Territory_ID__c> territories = new List<Territory_ID__c>();
        integer i = 0;
        for (String zipCode: zipCodes) {
            Territory_ID__c  territory = new Territory_ID__c();
            territory.City__c = 'Test City';
            territory.StateAbbr__c  = 'Test State';
            territory.County__c = 'Test County';
            territory.Name = zipcode;
            territory.Territory_Name__c = territorynames[i].Id;
            territory.Zip_Code__c = zipCode;
            
            territories.add(territory);
            i++;
        }
        DMLOperations dmlinsert = new DMLOperations(territories, 'insert');
        return territories;
    }
    
        public static List<TerritoryName__c> createTerritoryNames(Integer count, List<User> users) {
        
        List<TerritoryName__c> territorynames = new List<TerritoryName__c>();
        Integer usersize = users.size();
        string name = users[0].FirstName + ' ' + users[0].LastName;
        String amid = users[0].Id;
        
        String pcid;
        String rvpid;
        if(users.size() > 1){
            pcid = users[1].Id;
        }
        if(users.size() > 2){
            rvpid = users[2].Id;
        }
        
        for(integer i = 0; i < count; i++){
            TerritoryName__c tn = new TerritoryName__c(Name = name + i, Name__c = name, User__c = amid, Program_Consultant__c = pcid, Regional_VP__c = rvpid);
            territorynames.add(tn);
        }
        territorynames[1].User__c = pcid;
            
        DMLOperations dmlinsert = new DMLOperations(territorynames, 'insert');
        return territorynames;    
    }
    
    
    //---------------------------END OF BOB PHELPS CREATED TEST METHODS--------------------------------
    
    public static List<User> CreateUser(Set<String> usernames) {
        List<User> userList = new List<User>();
        
        for (String username : usernames) {
            //Get a profile id from the data base to assign to our user in this case make them a sys admin
            Profile p = [SELECT id FROM profile WHERE name = 'System Administrator'];
            
            //Create a new sys admin user and do an insert
            User u = new User(
                alias = 'standt',
                email = 'noEmail@testorg.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Testo',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = p.Id,
                timezonesidkey = 'America/Los_Angeles',
                username = username
            );
            
            userlist.add(u);
        }
        insert userlist;
        return userlist;
    }
    
    public static Id ACCOUNT_SCHOOL_RT_ID {
        get {
            if (ACCOUNT_SCHOOL_RT_ID == null) {
                ACCOUNT_SCHOOL_RT_ID = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'School'].Id;
            }
            return ACCOUNT_SCHOOL_RT_ID;
        }
        set;
    }
    
    public static Id ACCOUNT_DISTRICT_RT_ID {
        get {
            if (ACCOUNT_DISTRICT_RT_ID == null) {
                ACCOUNT_DISTRICT_RT_ID = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'District'].Id;
            }
            return ACCOUNT_DISTRICT_RT_ID;
        }
        set;
    }
    
    public static Id OPPORTUNITY_SALES_RT_ID {
        get {
            if (OPPORTUNITY_SALES_RT_ID == null) {
                OPPORTUNITY_SALES_RT_ID = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Sales_Opportunity'].Id;
            }
            return OPPORTUNITY_SALES_RT_ID;
        }
        set;
    }
    
    public static Account createDistrictAccount(String zipCode) {
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_DISTRICT_RT_ID;
        acc.Name = 'Test District Account';
        acc.ShippingPostalCode = zipCode;
        acc.ncesleaid__c = zipCode;
        acc.Status__c = 'Active';
        acc.No_NCES_Data__c = 'Not Found';
        return acc;
    }
    
    public static Account createSchoolAccount(String zipCode) {
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_SCHOOL_RT_ID;
        acc.Name = 'Test School Account';
        acc.ShippingPostalCode = zipCode;
        acc.ncessch__c = zipCode;
        acc.Status__c = 'Active';
        acc.No_NCES_Data__c = 'Not Found';
        return acc;
    }
    

    
    public static Opportunity createOpportunity(Id accountId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId;
        opp.Name = 'Test Opportunity';
        opp.RecordTypeId = OPPORTUNITY_SALES_RT_ID;
        opp.IsExcludedFromTerritory2Filter = true;
        opp.StageName = 'Target';
        opp.Confidence_Level__c = 'yes';
        opp.CloseDate = System.today().addMonths(1);
        opp.Interest_Source__c = 'Advisory board';
        return opp;
    }
    

    
    public static Contact createContact(Id accountId) {
        Contact con = new Contact();
        con.AccountId = accountId;
        con.LastName = 'Test Contact';
        con.Title = 'Director';
        return con;
    }
    

    
    public static TerritoryName__c createAccountManager(String name, String territoryId) {
        return createTerritoryName(name, 'Account Manager', territoryId);
    }
    
    public static TerritoryName__c createRegionalVicePresident(String name, String territoryId) {
        return createTerritoryName(name, 'Regional VP', territoryId);
    }
    
    public static TerritoryName__c createProgramConsultant(String name, String territoryId) {
        return createTerritoryName(name, 'Program Consultant', territoryId);
    }
    
    private static TerritoryName__c createTerritoryName(String name, String position, String territoryId) {
        TerritoryName__c tn = new TerritoryName__c();
        tn.Territory_ID__c = territoryId;
        tn.Position__c = name + ' - ' + position;
        tn.Name = name;
        tn.Name__c = name;
        tn.User__c = UserInfo.getUserId();
        return tn;
    }
  
}