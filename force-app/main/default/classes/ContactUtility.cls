/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class for operations on Contact records
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ehtiram Mammadzada <edd.mammadzada@gmail.com>
* @version        1.0
* @created        27-07-2021
* @systemLayer    Utility
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class ContactUtility {

    /**
    * @description Set owners of the given Accounts as owners of related Contacts
    * @param accMap Map with Account IDs set as key and Account records set as value
    */
    public static void setRelatedContactOwner(Map<Id, Account> accMap) {
        // Retrieve the related Contacts of given Accounts
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accMap.keySet()];
        if (!contacts.isEmpty()) {
            for (Contact con: contacts) {
                con.OwnerId = accMap.get(con.AccountId).OwnerId;
            }
            update contacts;
        }
    }
}