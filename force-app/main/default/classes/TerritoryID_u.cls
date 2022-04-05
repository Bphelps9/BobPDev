public with sharing class TerritoryID_u {
    
    List<String> tidFields = Utility.FieldNames('Territory_ID__c');
    List<String> tnFields = Utility.FieldNames('TerritoryName__c');
    public Territory_ID__c theTid = new Territory_ID__c();
    String query = 'Select ';
    String subquery = '(Select Id, Owner from Accounts)';
    Integer i = 0;    
    
    //building a dynamic query of all the fields in the Territory Id object given a trigger record
    //used when you have to do a before insert context on the same record
    public TerritoryID_u(Territory_ID__c tid){
        id tidid = tid.Id;
        for(String tidField : tidFields){
            if(i < tidFields.size()){
                query += tidField + ', ';
            } else query += tidfield;
            i += 1;
        }
        
        //reset for related object Territory_Name__r fields
        i=1;
        for(String tnField : tnFields){
            if(i < tnFields.size()){
                query += 'Territory_Name__r.' + tnField + ', ';
            } else query += 'Territory_Name__r.' + tnField;
            i += 1;
        }
        //query += subquery;
        query += ' from Territory_ID__c where Id = :tidid';
        
        system.debug('the TID query is ' + query);
        theTid = Database.query(query);
    }
}