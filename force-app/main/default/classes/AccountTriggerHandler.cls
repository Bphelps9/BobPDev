public class AccountTriggerHandler {
    /* Updated 2022-03-01 Bob Phelps to only fire when necessary to make the assignment changes
     */
    public static Boolean bypassTrigger = false;
    
    public AccountTriggerHandler() {}
    
    public void run() {
        if (bypassTrigger == true) {
            return;
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            assignCustomTerritories(Trigger.new);
            AccountUtility.setParentAccounts(Trigger.new);
        }
        else if (Trigger.isBefore && Trigger.isUpdate) {
            ownerChanged(Trigger.new, (Map<Id, Account>)Trigger.oldMap);//changed to call method to determine if the account owner changed on the trigger records
            AccountUtility.setParentAccountsOnUpdate(Trigger.new, (Map<Id, Account>)Trigger.oldMap);
        }
        else if (Trigger.isAfter && Trigger.isUpdate) {
            // reevaluateOpportunityTerritoryFilter();
        }
    }
    
    public static void ownerChanged(List<Account> accts, Map<Id, Account> oldMap){
        //on an update, only want to call assignCustomTerritories if the owner of the account changes
        List<Account> ownerChangedAccounts = new List<Account>();
        for(Account acct:accts){
            if(acct.OwnerId != oldMap.get(acct.Id).OwnerId){
                ownerChangedAccounts.add(acct);
            }
        }
        if(ownerChangedAccounts != null && ownerChangedAccounts.size() > 0 && !ownerChangedAccounts.isempty()){
            assignCustomTerritories(ownerChangedAccounts);
        }
    }

    public static List<Account> assignCustomTerritories(List<Account> accounts) {
        Set<String> postalCodes = new Set<String>();
        List<Account> accList = new List<Account>();
        Map<Id, String> overrideMap = new Map<Id, String>();
        for (Account acc: accounts) {
            if (acc.TerritoryOverride__c == 'Override by ID') {
            	postalCodes.add(acc.ShippingPostalCode);
            	accList.add(acc);
                overrideMap.put(acc.Id, acc.Territory_ID__c);
            } else if (String.isBlank(acc.TerritoryOverride__c)) {
            	postalCodes.add(acc.ShippingPostalCode);
            	accList.add(acc);
            }
        }
        // Collect accounts with modified owners
        Map<Id, Account> accMap = new Map<Id, Account>();
        TerritoryAssignmentHandler handler = new TerritoryAssignmentHandler(postalCodes, 'Account', overrideMap);
        for (Account acc: accList) {
            TerritoryAssignmentHandler.TerritoryStruct territoryDetails = handler.getTerritoryDetails(acc.Id, acc.ShippingPostalCode, acc.Special_Territory_Assignment__c);
            acc.Territory_ID__c = territoryDetails.territoryNumber;
            acc.Territory_Name__c = territoryDetails.territoryId;
            acc.AM__c = territoryDetails.am;
            acc.AMUser__c = territoryDetails.amId;
            acc.RVP__c = territoryDetails.rvp;
            acc.RVPUser__c = territoryDetails.rvpId;
            acc.PC__c = territoryDetails.pc;
            acc.PCUser__c = territoryDetails.pcId;
            acc.State__c = territoryDetails.state;
            acc.County__c = territoryDetails.county;

            if (!String.isBlank(territoryDetails.amId)) {
                acc.OwnerId = territoryDetails.amId;
                accMap.put(acc.Id, acc);
            }
        }
        // Update the Owners of related open Opportunities and Contacts
		OpportunityUtility.setRelatedOpenOpportunityOwner(accMap);
        ContactUtility.setRelatedContactOwner(accMap);
        return accList;
    }
}