public with sharing class DMLOperations {
    /*insert class heading snippet here
     * this is the database domain layer. All DML operation in our code should take place here 
     * for consistent success and failure handling
     * */
    
    List<Database.SaveResult> srlist = new List<Database.SaveResult>();
    List<Database.DeleteResult> drlist = new List<Database.DeleteResult>();
    public Map<String, String> dmlresults = new Map<String, String>();
    public DMLOperations(List<Sobject> theObjects, String dmlContext){
        if(dmlContext == 'insert'){
            this.srList = Database.insert(theObjects, false);
            saveresulthandling();
        } else if(dmlContext == 'update'){
            this.srList = Database.update(theObjects, false);
            saveresulthandling();
        } else if(dmlContext == 'delete'){
            this.drList = Database.delete(theObjects, false);
            deleteresulthandling();
        }
    }        
    
    private void saveresulthandling(){
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                dmlresults.put('Success', sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    dmlresults.put('Error', err.getMessage());
                }
            }
        }
    }
    
    private void deleteresulthandling(){
        /*handle this when we need to delete records
for (Database.SaveResult sr : srList) {
if (sr.isSuccess()) {
// Operation was successful, so get the ID of the record that was processed
System.debug('Successfully inserted account. Account ID: ' + sr.getId());
}
else {
// Operation failed, so get all errors                
for(Database.Error err : sr.getErrors()) {
System.debug('The following error has occurred.');                    
System.debug(err.getStatusCode() + ': ' + err.getMessage());
System.debug('Account fields that affected this error: ' + err.getFields());
}
}
}*/
    }
    
}