@isTest
public class AccountTriggerTest {
    
    @isTest
    private static void beforeInsertTerritoryAssignment() {
        Account acc = TestFactory.createSchoolAccount('12345');
        List<String> zipCodes = new List<String>();
        zipCodes.add(acc.ShippingPostalCode);

        String territoryId = '99';
        List<Territory_ID__c> territories = TestFactory.createTerritories(territoryId, zipCodes);
        insert territories;
        List<TerritoryName__c> positions = new List<TerritoryName__c>();
        TerritoryName__c am = TestFactory.createAccountManager('Lincoln Turner', territoryId);
		positions.add(am);
        TerritoryName__c rvp = TestFactory.createRegionalVicePresident('John Appleseed', territoryId);
		positions.add(rvp);
        TerritoryName__c pc = TestFactory.createProgramConsultant('Cathy Smith', territoryId);
        positions.add(pc);
        insert positions;
        
        
        Test.startTest();
        	insert acc;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, Territory_Name__c, Territory_ID__c, AM__c, PC__c, RVP__c, State__c, County__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(am.Id, updatedAcc.Territory_Name__c);
        System.assertEquals(territoryId, updatedAcc.Territory_ID__c);
        System.assertEquals(am.Name, updatedAcc.AM__c);
        System.assertEquals(pc.Name, updatedAcc.PC__C);
        System.assertEquals(rvp.Name, updatedAcc.RVP__C);
        System.assertEquals(territories[0].StateAbbr__c, updatedAcc.State__c);
        System.assertEquals(territories[0].County__c, updatedAcc.County__c);
        System.assertEquals(am.User__c, updatedAcc.OwnerId);
    }

    @isTest
    private static void beforeInsertTerritoryAssignmentOverride() {
        Account acc = TestFactory.createSchoolAccount(null);
        acc.TerritoryOverride__c = 'Override by ID';
        acc.Territory_ID__c = '99';
        List<String> zipCodes = new List<String>();
        zipCodes.add(acc.ShippingPostalCode);

        String territoryId = '99';
        List<Territory_ID__c> territories = TestFactory.createTerritories(territoryId, zipCodes);
        insert territories;
        List<TerritoryName__c> positions = new List<TerritoryName__c>();
        TerritoryName__c am = TestFactory.createAccountManager('Lincoln Turner', territoryId);
		positions.add(am);
        TerritoryName__c rvp = TestFactory.createRegionalVicePresident('John Appleseed', territoryId);
		positions.add(rvp);
        TerritoryName__c pc = TestFactory.createProgramConsultant('Cathy Smith', territoryId);
        positions.add(pc);
        insert positions;
        
        
        Test.startTest();
        	insert acc;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, Territory_Name__c, Territory_ID__c, AM__c, PC__c, RVP__c, State__c, County__c, ShippingPostalCode, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(null, updatedAcc.ShippingPostalCode);
        System.assertEquals(am.Id, updatedAcc.Territory_Name__c);
        System.assertEquals(territoryId, updatedAcc.Territory_ID__c);
        System.assertEquals(am.Name, updatedAcc.AM__c);
        System.assertEquals(pc.Name, updatedAcc.PC__C);
        System.assertEquals(rvp.Name, updatedAcc.RVP__C);
        System.assertEquals(territories[0].StateAbbr__c, updatedAcc.State__c);
        System.assertEquals(territories[0].County__c, updatedAcc.County__c);
        System.assertEquals(am.User__c, updatedAcc.OwnerId);
    }

    @isTest
    public static void beforeInsertSetParentAccountByNCESID() {
        Account district = TestFactory.createDistrictAccount('09876');
        district.ncesleaid__c = 'NCES09876';
        insert district;
        
        Account school = TestFactory.createSchoolAccount('12345');
        school.ParentNcesId__c = 'NCES09876';

		System.assertEquals(null, school.ParentAccountTEST__c);
        Test.startTest();
        	insert school;
        Test.stopTest();
        ParentAccountAssignmentSetting__mdt setting = [SELECT Id, ParentField__c FROM ParentAccountAssignmentSetting__mdt LIMIT 1];
        Account updatedSchool = [SELECT Id, ParentAccountTEST__c, ParentId FROM Account WHERE Id = :school.Id];
        System.assertEquals(district.Id, updatedSchool.get(setting.ParentField__c));
    }
    
    @isTest
    public static void beforeUpdateSetParentAccountByNCESID() {
        AccountTriggerHandler.bypassTrigger = true;
            Account district = TestFactory.createDistrictAccount('09876');
            district.ncesleaid__c = 'NCES09876';
            insert district;
        AccountTriggerHandler.bypassTrigger = false;
        
        Account school = TestFactory.createSchoolAccount('12345');
        insert school;

        Account updatedSchool = [SELECT Id, ParentAccountTEST__c, ParentId FROM Account WHERE Id = :school.Id];
		System.assertEquals(null, school.ParentAccountTEST__c);
        Test.startTest();
            school.ParentNcesId__c = 'NCES09876';
			update school;
        Test.stopTest();
        ParentAccountAssignmentSetting__mdt setting = [SELECT Id, ParentField__c FROM ParentAccountAssignmentSetting__mdt LIMIT 1];
        updatedSchool = [SELECT Id, ParentAccountTEST__c, ParentId FROM Account WHERE Id = :school.Id];
        System.assertEquals(district.Id, updatedSchool.get(setting.ParentField__c));
    }

    @isTest
    private static void beforeUpdateTerritoryAssignment() {
        Account acc = TestFactory.createSchoolAccount('12345');
        insert acc;
        Opportunity opp = TestFactory.createOpportunity(acc.Id);
        insert opp;
		Contact con = TestFactory.createContact(acc.Id);
        insert con;

        String territoryId = '99';
        List<String> zipCodes = new List<String>();
        zipCodes.add('98765');
        List<Territory_ID__c> territories = TestFactory.createTerritories(territoryId, zipCodes);
        insert territories;
        List<TerritoryName__c> positions = new List<TerritoryName__c>();
        TerritoryName__c am = TestFactory.createAccountManager('Lincoln Turner', territoryId);
		positions.add(am);
        TerritoryName__c rvp = TestFactory.createRegionalVicePresident('John Appleseed', territoryId);
		positions.add(rvp);
        TerritoryName__c pc = TestFactory.createProgramConsultant('Cathy Smith', territoryId);
        positions.add(pc);
        insert positions;

        Test.startTest();
        	acc.ShippingPostalCode = '98765';
        	update acc;
        Test.stopTest();
        
        Account updatedAcc = [SELECT Id, Territory_Name__c, Territory_ID__c, AM__c, PC__c, RVP__c, State__c, County__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(am.Id, updatedAcc.Territory_Name__c);
        System.assertEquals(territoryId, updatedAcc.Territory_ID__c);
        System.assertEquals(am.Name, updatedAcc.AM__c);
        System.assertEquals(pc.Name, updatedAcc.PC__C);
        System.assertEquals(rvp.Name, updatedAcc.RVP__C);
        System.assertEquals(territories[0].StateAbbr__c, updatedAcc.State__c);
        System.assertEquals(territories[0].County__c, updatedAcc.County__c);
        System.assertEquals(am.User__c, updatedAcc.OwnerId);
        
        Opportunity updatedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(am.User__c, updatedOpp.OwnerId);
        
        Contact updatedCon = [SELECT Id, OwnerId FROM Contact WHERE Id = :con.Id];
        System.assertEquals(am.User__c, updatedCon.OwnerId);
    }
    
/* OBSOLETE TESTS - TERRITORY HIERARCHY DISABLED 
    @isTest
    private static void afterUpdateOpportunityTerritoryUpdate() {
        // Get Active Territory Model
        Account acc = createInsertAccount();
        Opportunity opp = createInsertOpportunity(acc.Id);
        Territory2Model model = [SELECT Id FROM Territory2Model WHERE State = 'Active' LIMIT 1];
        List<ObjectTerritory2Association> existingAssociations = [SELECT Id FROM ObjectTerritory2Association WHERE ObjectId = :acc.Id];
        Territory2 ter = [SELECT Id FROM Territory2 WHERE Territory2ModelId = :model.Id LIMIT 1];
        ObjectTerritory2Association acc2territory = new ObjectTerritory2Association();
        acc2territory.ObjectId = acc.Id;
        acc2territory.Territory2Id = ter.Id;
        acc2territory.AssociationCause = 'Territory2Manual';
        insert acc2territory;

        opp = [SELECT Id, Territory2Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
        System.assertNotEquals(ter.Id, opp.Territory2Id, 'Opportunity shall not have a territory');
        Test.startTest();
            acc.Name = 'Test Update';
            update acc;
        Test.stopTest();
        Opportunity updatedOpp = [SELECT Id, Territory2Id FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(ter.Id, updatedOpp.Territory2Id, 'Expected territory Id was not set');
    }

    private static Account createInsertAccount() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'School'].Id;
        acc.Status__c = 'Active';
        acc.ncessch__c = '00001';
        insert acc;
        return acc;
    }

    private static Opportunity createInsertOpportunity(Id accountId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accountId;
        opp.Name = 'Test Opportunity for School';
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Sales_Opportunity'].Id;
        opp.IsExcludedFromTerritory2Filter = true;
        opp.StageName = 'Target';
        opp.CloseDate = System.today().addMonths(1);
        opp.Confidence_Level__c = 'yes';
        insert opp;
        return opp;
    }
*/
}