public class ActivityPolymorphicLookupHandler {

    private final List<sObject> records;
    
    private static final SObjectType accountSObject = Account.getSObjectType();
    private static final SObjectType opportunitySObject = Opportunity.getSObjectType();
    private static final SObjectType contactSObject = Contact.getSObjectType();

    public static void mapWhatId(sObject record) {
        record.put('Account__c', null);
        record.put('Opportunity__c', null);
        Id parentId = (Id) record.get('WhatId');
        if (parentId != null) {
            SObjectType parentType = parentId.getSobjectType();
            if (parentType == accountSObject) {
                record.put('Account__c', parentId);
            } else if (parentType == opportunitySobject) {
                record.put('Opportunity__c', parentId);
            }
        }
    }
    
    public static void mapWhoId(sObject record) {
        record.put('Contact__c', null);
        Id nameId = (Id) record.get('WhoId');
        if (nameId != null) {
            SObjectType nameType = nameId.getSobjectType();
            if (nameType == contactSobject) {
                record.put('Contact__c', nameId);
            }
        }
    }
}