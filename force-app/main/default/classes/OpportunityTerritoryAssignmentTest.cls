@isTest
public class OpportunityTerritoryAssignmentTest {
/* OBSOLETE TESTS - TERRITORY HEIRARCHY DISABLED
    @testSetup
    private static void setup() {
        // Prepare Account and Opportunity records for test
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'School'].Id;
        acc.Status__c = 'Active';
        acc.ncessch__c = '00001';
        insert acc;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity for School';
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Sales_Opportunity'].Id;
        opp.IsExcludedFromTerritory2Filter = true;
        opp.StageName = 'Target';
        opp.Confidence_Level__c = 'yes';
        opp.CloseDate = System.today().addMonths(1);
        insert opp;
    }

    @isTest
    private static void afterUpdateSetTerritory() {
        // Get Active Territory Model
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Territory2Model model = [SELECT Id FROM Territory2Model WHERE State = 'Active' LIMIT 1];
        Territory2 ter = [SELECT Id FROM Territory2 WHERE Territory2ModelId = :model.Id LIMIT 1];
        // Assign the Account to the Territory
        ObjectTerritory2Association acc2territory = new ObjectTerritory2Association();
        acc2territory.ObjectId = acc.Id;
        acc2territory.Territory2Id = ter.Id;
        acc2territory.AssociationCause = 'Territory2Manual';
        insert acc2territory;
        Test.startTest();
            // Pass the opportunity to the APEX class to retrieve the territory
            Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
            OpportunityTerritoryAssignment terAsn = new OpportunityTerritoryAssignment();
        Map<Id, Id> terMap = terAsn.getOpportunityTerritory2Assignments(new List<Id> {opp.Id});
        Test.stopTest();
        // Ensure the right territory is returned in the pair
        Id oppTerId = terMap.get(opp.Id);
        System.assertEquals(ter.Id, oppTerId, 'Expected territory Id was not returned');
    }
*/
}