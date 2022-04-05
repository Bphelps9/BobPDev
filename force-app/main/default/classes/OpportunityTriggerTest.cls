@isTest
public class OpportunityTriggerTest {
/* OBSOLETE TESTS - TERRITORY HIERARCHY DISABLED
    @testSetup
    private static void setup() {
        Account acc = createInsertAccount();

        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity for School';
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Sales_Opportunity'].Id;
        opp.IsExcludedFromTerritory2Filter = false;
        opp.StageName = 'Target';
        opp.Confidence_Level__c = 'yes';
        opp.CloseDate = System.today().addMonths(1);
        insert opp;
    }

    @isTest
    private static void afterUpdateSetTerritory() {
        // Get Active Territory Model
        Account originalAcc = [SELECT Id FROM Account LIMIT 1];
        Territory2Model model = [SELECT Id FROM Territory2Model WHERE State = 'Active' LIMIT 1];
        List<ObjectTerritory2Association> existingAssociations = [SELECT Id FROM ObjectTerritory2Association WHERE ObjectId = :originalAcc.Id];
        Territory2 ter;
        if (existingAssociations == null || existingAssociations.isEmpty()) {
            List<Id> territoryIds = new List<Id>();
            for (ObjectTerritory2Association association: existingAssociations) {
                territoryIds.add(association.Territory2Id);
            }
            ter = [SELECT Id FROM Territory2 WHERE Id NOT IN :territoryIds LIMIT 1];
        } else {
            ter = [SELECT Id FROM Territory2 WHERE Territory2ModelId = :model.Id LIMIT 1];
        }
        Account acc = createInsertAccount();
        ObjectTerritory2Association acc2territory = new ObjectTerritory2Association();
        acc2territory.ObjectId = acc.Id;
        acc2territory.Territory2Id = ter.Id;
        acc2territory.AssociationCause = 'Territory2Manual';
        insert acc2territory;

        Opportunity opp = [SELECT Id, Territory2Id FROM Opportunity WHERE AccountId = :originalAcc.Id LIMIT 1];
        System.assertNotEquals(ter.Id, opp.Territory2Id, 'Opportunity shall not have a territory');
        Test.startTest();
            // Updating the Account ID will fire the process to update the Territory value
            opp.AccountId = acc.Id;
            update opp;
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
*/
}