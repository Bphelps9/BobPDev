trigger TerritoryTrigger on Territory_ID__c (after insert,after update) {
/*
    list<String> codes = new list<String>();
    for(Territory_ID__c  territory:Trigger.New)
    {
        codes.add(territory.Zip_Code__c);
    }
    list<Account> accs = [SELECT id,Territory_ID__c  FROM Account WHERE ShippingPostalCode in :codes];
    if(accs.size()>0)
    {
         update accs;
    }
*/
}