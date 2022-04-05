@isTest
public class DMLOperations_t {
    
    @isTest
    public static void insertsuccess(){
        List<String> zipcodes = Utility.generatezipcodes(1);
        test.startTest();
        List<Account> accounts = TestFactory.createSchoolAccounts(zipCodes);
        test.stopTest();
    }
    
    @isTest
    public static void insertfail(){
        List<String> zipcodes = Utility.generatezipcodes(1);
        for (Integer i = 0; i < zipcodes.size(); i++) {
            zipcodes[i] = zipcodes[i] + '9';
        }
        system.debug('the fail zip code is ' + zipcodes[0]);
        test.startTest();
        List<Account> accounts = TestFactory.createSchoolAccounts(zipCodes);
        test.stopTest();
    }
    
        @isTest
    public static void updatesuccess(){
        List<String> zipcodes = Utility.generatezipcodes(1);
        List<Account> accounts = TestFactory.createSchoolAccounts(zipCodes);
        
        test.startTest();
        accounts[0].Name = 'Test Update DML';
        DMLOperations dmlupdate = new DMLOperations(accounts, 'update');
        test.stopTest();
    }
    
        @isTest
    public static void deletesuccess(){
        List<String> zipcodes = Utility.generatezipcodes(1);
        List<Account> accounts = TestFactory.createSchoolAccounts(zipCodes);
        
        test.startTest();
        DMLOperations dmlDelete = new DMLOperations(accounts, 'delete');
        test.stopTest();
    }
}