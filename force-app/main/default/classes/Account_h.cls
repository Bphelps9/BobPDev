public with sharing class Account_h {
    /*insert class heading snippet here
* 
* 
*/
    private List<Account> oldAccounts = new List<Account>();
    private List<Account> newAccounts = new List<Account>();
    private Map<Id, Account> oldAccountsMap = new Map<Id, Account>();
    private Map<Id, Account> newAccountsMap = new Map<Id, Account>();
    private string triggercontext;
    
    public Account_h(){
        
    }
    
    public void beforeInsert(List<Account> accts){
        this.newAccounts = accts;
        triggercontext = 'before insert';
        wrapper(triggercontext);
    }
    
    public void afterInsert(List<Account> accts){
        this.newAccounts = accts;
        triggercontext = 'after insert';
        wrapper(triggercontext);
    }
    
    public void beforeUpdate(List<Account> accts, Map<Id, Account> oldAcctsMap){
        this.newAccounts = accts;
        this.oldAccountsMap = oldAcctsMap;
        triggercontext = 'before update';
        wrapper(triggercontext);
    }
    
    public void afterUpdate(List<Account> accts, Map<Id, Account> oldAcctsMap){
        this.newAccounts = accts;
        this.oldAccountsMap = oldAcctsMap;
        triggercontext = 'after update';
        wrapper(triggercontext);
    }
    
    private void wrapper(String triggercontext) {
        if(triggercontext.contains('insert')){
            for(Account newAccount : newAccounts){
                Account_w accountWrapper = new Account_w(newAccount, triggercontext);
                if(accountWrapper.dmlResults != null || !accountWrapper.dmlResults.isempty()){
                    system.debug(accountWrapper.dmlResults); //TODO add some error handling and messaging
                }
            }
        } else if(triggercontext.contains('update')){
            for(Account newAccount : newAccounts){
                system.debug('trigger context: ' + triggercontext + ' old owner id is ' + oldAccountsMap.get(newAccount.Id).OwnerId + ' and new Owner id is ' + newAccount.OwnerId);
                Account_w accountWrapper = new Account_w(oldAccountsMap.get(newAccount.Id), newAccount, triggercontext);
                if(accountWrapper.dmlResults != null || !accountWrapper.dmlResults.isempty()){
                    system.debug(accountWrapper.dmlResults); //TODO add some error handling and messaging
                }
            }
        }
    }
    
    
}