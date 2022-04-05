public class Account_u {
    /*Insert Header Text Here
* 
*/
    
    public Account theAccount = new Account();
    public List<Opportunity> relatedOpps = new List<Opportunity>();
    public List<Contact> relatedContacts = new List<Contact>();
    
    //this utility re-queries the Account record in the trigger and also gets various related fields to the account as well as child object subqueries
    //Using this query should minimize the need to query for these things separately
    public Account_u (Account acct, Boolean masterquery){
        if(masterquery == true){
            this.theAccount = [Select Id, Name, OwnerId, Owner.IsActive, ParentID, Parent.Parent.ID, (Select Id, FirstName, LastName, Email, OwnerId, Owner.IsActive from Contacts), (Select Id, Name, StageName, OwnerId, Owner.IsActive from Opportunities) from Account where Id = :acct.Id];
            relatedOpps = theAccount.Opportunities;
            relatedContacts = theAccount.Contacts;
        } else this.theAccount = acct;
    }
    
}