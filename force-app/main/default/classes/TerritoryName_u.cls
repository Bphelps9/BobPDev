public with sharing class TerritoryName_u {
    
    List<String> tnFields = Utility.FieldNames('TerritoryName__c');
    public TerritoryName__c theTn = new TerritoryName__c();
    String query = 'Select ';
    String subquery = '(Select Id, Owner from TerritoryIDs)';
    Integer i = 1; 
    
    //building a dynamic query of all the fields in the Territory Name object given a trigger record
    //used when you have to do a before insert context on the same record
    public TerritoryName_u(TerritoryName__c tn){
        Id tnid = tn.Id;
        for(String tnField : tnFields){
            if(i < tnFields.size()){
                query += tnField + ', ';
            } else query += tnfield;
            i += 1;
        }
        //query += subquery;
        query += ' from TerritoryName__c where Id = :tnid';
        
        system.debug('the TN query is ' + query);
        theTn = Database.query(query);
    }
}