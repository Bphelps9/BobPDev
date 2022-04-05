public class Utility {
    /* Author: Bob Phelps 
    * 
    *  Date Created: 03/23/2022    
    * 
    *  Purpose: General Utility Functions
    *  
    *  Modification History:
    *  Date / Author  / Description
    *  -------------  ------------------  --------------------------------------------------------------------------------------------------------------

    */

    public static Boolean isNullorEmpty(List<Object> ol) {
        Boolean isIt = true;
        if (ol != null) {
            if (ol.Size() > 0) {
                isIt = false;
            }
        }
        return isIt;
    }

    public static Boolean firedmethod = null;

    public static Boolean AccountSN = false;

    public static Boolean firstrun = true;

    //next 2 utilities are for use in the one-time creation of cpa and revshares when used in the MCN create process
    public static Boolean deactivaterevshares = false;

    public static String deactivatecpa;

    public static integer j;

    public static Boolean dupechecked = false;

    public static Integer increment1() {
        if (firstrun == true) {
            j = 1;
        } else {
            j = j + 1;
        }
        firstrun = false;
        return j;
    }
    /*probably don't need this because I'm storing the above in a static variable
    public static integer storedincrement(integer j){
        integer k = j;
        if(k == null){
            k = 0;
        }
        return k;
    }
*/

    public static Map<String, Id> GetRecordTypes(String objectName) {
        Map<String, Id> rtmap = new Map<String, Id>();

        List<RecordType> rts = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = :objectName]);
        for (RecordType rt : rts) {
            rtmap.put(rt.DeveloperName, rt.Id);
        }
        return rtmap;
    }

    public static List<String> FieldNames(String objectName) {
        List<String> fieldstoReturn = new List<String>();
        String fields = '';
        List<String> tableList = new List<String>();
        tableList.add(objectName);
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(tableList);
        List<String> fieldsToQuery = new List<String>(descResult[0].fields.getMap().keySet());
        return fieldsToQuery;
    }

    public static String Fields(String objectName) {
        return Fields(objectName, false);
    }

    public static String Fields(String objectName, Boolean includeSystemFields) {
        //ownerid, isdeleted, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, connectionreceivedid, connectionsentid,
        List<String> fieldstoReturn = new List<String>();
        List<String> systemFields = new List<String>{
            'ownerid',
            'isdeleted',
            'createddate',
            'createdbyid',
            'lastmodifieddate',
            'lastmodifiedbyid',
            'systemmodstamp',
            'lastactivitydate',
            'lastvieweddate',
            'lastreferenceddate',
            'connectionreceivedid',
            'connectionsentid',
            'masterrecordid'
        };
        String fields = '';
        List<String> tableList = new List<String>();
        System.debug('the object name in the fields method is ' + objectName);
        tableList.add(objectName);
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(tableList);
        for (Schema.DescribeSObjectResult dr : descResult) {
            Set<String> fieldsToQuery = dr.fields.getMap().keySet();
            if (includeSystemFields == false) {
                for (String fieldName : fieldsToQuery) {
                    if (systemFields.contains(fieldName) == false) {
                        fieldstoReturn.add(fieldName);
                    }
                }
            } else {
                fieldsToReturn = new List<String>(fieldstoQuery);
            }
        }
        system.debug('the fields returned by the fields method is ' + String.join(fieldsToReturn, ', '));
        return String.join(fieldsToReturn, ', ');
    }

    public static Map<Sobject, Map<String, String>> fieldvaluesmap(Sobject Sobj) {
        Map<String, String> fieldvaluesmap = new Map<String, String>();
        Map<Sobject, Map<String, String>> relatedobjfieldvaluesmap = new Map<Sobject, Map<String, String>>();
        Map<Sobject, Map<String, String>> objfieldvaluesmap = new Map<Sobject, Map<String, String>>();
        Set<Id> relatedids = new Set<Id>();
        String sobjname = Sobj.getSObjectType().getDescribe().getName();
        List<String> fields = new List<String>();
        fields = Fields(sobjname, false).Split(', ');
        for (String field : fields) {
            system.debug('fieldname is ' + field);
            fieldvaluesmap.put(field, string.valueof(Sobj.get(field)));
            string fieldstring = string.valueof(Sobj.get(field));
            system.debug('fieldstring equals ' + fieldstring);
            if (fieldstring instanceof Id) {
                relatedids.add(Id.valueof(fieldstring));
            }
        }
        objfieldvaluesmap.put(Sobj, fieldvaluesmap);
        /*commenting this out for now as the related object field values just return null values
        if (isNullorEmpty(relatedids) == false) {
            relatedobjfieldvaluesmap = getrelatedobjectfieldvalue(relatedids);
        }

        objfieldvaluesmap.putAll(relatedobjfieldvaluesmap);
*/
        return objfieldvaluesmap;
    }

    public static Boolean HasField(String objectTypeName, String fieldName) {
        //Usage: if (Utility.HasField('Account', 'Manufacturer_Authority__c'))
        //Note:  this method is intended to detect if an object has a valid column name for the HasValue method below
        // but can also be used to determine if a field exists (because of potential differences between production and
        // sandbox environments) or has been removed from an object
        try {
            SObjectType objectType = Schema.getGlobalDescribe().get(objectTypeName);
            Set<String> objectFields = objectType.getDescribe().fields.getMap().keySet();
            return objectFields.contains(fieldName.toLowerCase());
        } catch (Exception ex) {
        }
        return false;
    }

    public static Boolean HasValue(SObject obj, String objectTypeName, String fieldName) {
        //Usage: if (Utility.HasValue(someAccount, 'Account', 'Manufacturer_Authority__c'))
        if (HasField(objectTypeName, fieldName)) {
            try {
                SObjectType objectType = Schema.getGlobalDescribe().get(objectTypeName);
                Set<String> objectFields = objectType.getDescribe().fields.getMap().keySet();
                return (obj.get(fieldName.toLowerCase()) != null);
            } catch (Exception ex) {
            }
        }
        return false;
    }

    public static String GetJSON(ID theID) {
        String className = theID.getSObjectType().getDescribe().getName();
        string fields = Utility.fields(className);
        string stringid = '\'' + theID + '\'';
        string soql = 'select ' + fields + ' from ' + className + ' where id = ' + stringid;
        List<sObject> theList = database.query(soql);
        if (Utility.isNullorEmpty(theList))
            return null;
        return json.serialize(theList[0]);
    }

    public static Object FirstItem(List<Object> ol) {
        //Usage:  Integer myVar = (Integer)Utility.FirstItem(il);
        Object obj = null;
        if (ol != null) {
            if (!ol.isEmpty()) {
                obj = ol.get(0);
            }
        }
        return obj;
    }

    public static Object LastItem(List<Object> ol) {
        //Usage:  Integer myVar = (Integer)Utility.LastItem(il);
        Object obj = null;
        if (ol != null) {
            if (!ol.isEmpty()) {
                obj = ol.get(ol.Size() - 1);
            }
        }
        return obj;
    }

    public static void RemoveItem(List<SObject> lst, SObject itemtoremove) {
        //Usage:  Utility.RemoveItem(targetList<Account>, acctToRemove)
        for (Integer i = lst.size() - 1; i >= 0; --i) {
            if (lst.get(i) == itemtoremove || lst.get(i).get('id') == itemtoremove.get('id')) {
                lst.remove(i);
            }
        }
    }

    public static void RemoveItem(List<SObject> lst, ID idtoremove) {
        //Usage:  Utility.RemoveItem(targetList<Account>, acctToRemove)
        for (Integer i = lst.size() - 1; i >= 0; --i) {
            if (lst.get(i).Id == idtoremove) {
                lst.remove(i);
            }
        }
    }

    public static void RemoveItems(List<SObject> lst, List<SObject> items) {
        //Usage:  Utility.RemoveItems(targetList<Account>, itemList<Account>)
        for (Integer i = lst.size() - 1; i >= 0; --i) {
            if (items.contains(lst.get(i))) {
                lst.remove(i);
            }
        }
    }

    public static void RemoveItems(List<SObject> lst, List<ID> idList) {
        //Usage:  Utility.RemoveItems(targetList<Account>, idList<ID>)
        for (Integer i = lst.size() - 1; i >= 0; --i) {
            if (idList.contains(lst.get(i).Id)) {
                lst.remove(i);
            }
        }
    }

    public static Map<String, String> PicklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{ objectName });
        if (isNullorEmpty(results) == true)
            return null;
        for (Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        return values;
    }

    public static Boolean IsPickListValue(String objectName, String fieldName, String checkValue) {
        Map<String, String> theValues = PicklistValues(objectName, fieldName);
        if (theValues != null) {
            return theValues.containsKey(checkValue);
        }
        return false;
    }

    public static String getClassMethod() {
        return getClassMethod(0);
    }

    public static String getClassMethod(Integer index) {
        String returnValue = 'Unknown Class.Method';
        try {
            throw new DmlException();
        } catch (DmlException e) {
            List<String> stackArray = new List<String>();
            List<String> tempArray = e.getStackTraceString().split('\n');
            if (IsNullorEmpty(tempArray) == false) {
                for (String line : tempArray) {
                    if (line.startsWith('Class.') == true)
                        line = line.substringAfter('Class.');
                    if (line.contains(':') == true)
                        line = line.substringBefore(':');
                    if (line != 'Utility.getClassMethod') {
                        stackArray.add(line);
                    }
                }
                if (index < stackArray.size()) {
                    returnValue = stackArray[index];
                    if (returnValue.startsWith('Class.') == true)
                        returnValue = returnValue.substringAfter('Class.');
                    if (returnValue.contains(':') == true)
                        returnValue = returnValue.substringBefore(':');
                }
            }
        }
        return returnValue;
    }

    //method to output the contents of a specific report
    public static void DisplayReport(String reportID) {
        string filterline;
        string cr = '\n';
        string line = cr + reportID + cr;

        Reports.ReportDescribeResult rptDescribe = Reports.ReportManager.describeReport(reportId);
        // get report metadata
        Reports.ReportMetadata rptMetadata = rptDescribe.getReportMetadata();
        line += rptMetadata.getName() + cr;
        Reports.ReportType rt = rptMetadata.getReportType();
        line += rt.getLabel() + ': ' + rt.getType() + cr + cr;

        line += 'Columns:' + cr + cr;
        List<String> rptColumns = rptMetadata.getDetailColumns();
        for (String s : rptColumns) {
            line += s + cr;
        }
        line += cr + 'Filters:' + cr + cr;
        List<Reports.ReportFilter> rptFilters = rptMetadata.getReportFilters();
        for (Reports.ReportFilter rptFilter : rptFilters) {
            filterline = rptFilter.getColumn() + ' ' + rptFilter.getOperator() + ' ' + rptFilter.getValue();
            line += filterline + cr;
        }
        system.debug(line);
    }
/*
    //method added 09/28/2020 to allow record updates to specific objects to be deferred in case of locking conflicts
    public static integer updateSOBs(List<sObject> SOBs) {
        Integer countDeferred = 0;
        if (SOBs != null && SOBS.isEmpty() == false) {
            String objectType = SOBS[0].getSObjectType().getDescribe().getName();
            String errorMessage = '';
            List<DeferredProcess__c> defs = new List<DeferredProcess__c>();
            DeferredProcess__c deferred;

            SystemSingleton SystemSN = SystemSingleton.getInstance();
            if (SystemSN.getDeferment() == false) {
                Database.SaveResult[] resultList = Database.update(SOBS, false);
                //Iterate the results
                for (integer i = 0; i < resultList.size(); i++) {
                    if (resultList[i].isSuccess() == false) {
                        //failed, so throw it in the queue for deferred processing
                        for (Database.Error err : resultList[i].getErrors()) {
                            ErrorMessage += err.getStatusCode() + ': ' + err.getMessage() + '; ';
                        }
                        if (errorMessage.length() > 255) {
                            errorMessage = errorMessage.abbreviate(255);
                        }
                        deferred = new DeferredProcess__c(
                            ObjectID__c = SOBS[i].Id,
                            ObjectType__c = objectType,
                            ObjectContent__c = JSON.serialize(SOBS[i]),
                            ProcessType__c = 'Update',
                            Scheduled__c = Datetime.now(),
                            ErrorMsg__c = errorMessage,
                            Attempts__c = 0
                        );
                        defs.add(deferred);
                    }
                }
            } else {
                system.debug('Forcing Test of lock conflict deferment');
                SystemSN.setDeferment(false);
                errorMessage = 'Test of lock conflict deferment';
                for (integer i = 0; i < SOBS.size(); i++) {
                    deferred = new DeferredProcess__c(
                        ObjectID__c = SOBS[i].Id,
                        ObjectType__c = objectType,
                        ObjectContent__c = JSON.serialize(SOBS[i]),
                        ProcessType__c = 'Update',
                        Scheduled__c = Datetime.now(),
                        ErrorMsg__c = errorMessage,
                        Attempts__c = 0
                    );
                    defs.add(deferred);
                }
            }
            if (defs.isEmpty() == false) {
                countDeferred = defs.size();
                insert defs;
            }
        }
        return countDeferred;
    }
*/
    public static Decimal rollupsummary(List<SObject> objlist, string objname, string fldname, string fnctn, string condition) {
        /*Bob Phelps this utility method provides a roll up summary function given an
object name and, if applicable, a field name and aggregate function. If only the object name is given
we just count the number of records returned. Otherwise we use the field name and fcntn to return
an aggregate value such as Sum, Max, Min and Avg
*/
        Decimal rusvalue;
        string query;
        string agname = fldname + fnctn;

        if (fldname != null && fnctn != null) {
            //if a field and function are passed then we use an aggregate result query to return the value
            AggregateResult[] agresult;
            query = 'Select ' + fnctn + '(' + fldname + ') ' + agname + ' from ' + objname + ' where ' + condition;
            agresult = Database.query(query);
            rusvalue = (Decimal) agresult[0].get(agname);
        } else {
            //otherwise we just count the number of records returned
            query = 'Select Id from ' + objname + ' where ' + condition;
            objlist = Database.query(query);
            if (!objlist.isempty() && objlist != null) {
                rusvalue = objlist.size();
            } else {
                rusvalue = 0;
            }
        }
        return rusvalue;
    }

    public static Date rollupsummaryDate(List<SObject> objlist, string objname, string fldname, string fnctn, string condition) {
        /* created 04-02-202 Bob Phelps this utility method provides a roll up summary function given an
        object name and, if applicable, a field name and aggregate function. If only the object name is given
        we just count the number of records returned. Otherwise we use the field name and fcntn to return
        an aggregate value such as Sum, Max, Min and Avg
        */
        Date rusvalue;
        string query;
        string agname = fldname + fnctn;

        if (fldname != null && fnctn != null) {
            //if a field and function are passed then we use an aggregate result query to return the value
            AggregateResult[] agresult;
            query = 'Select ' + fnctn + '(' + fldname + ') ' + agname + ' from ' + objname + ' where ' + condition;
            system.debug('the query used is ' + query);
            agresult = Database.query(query);
            rusvalue = (Date) agresult[0].get(agname);
        } else {
            //here we HAVE to return a date value or null
            //query = 'Select Id from ' + objname  + ' where ' + condition;
            objlist = Database.query(query);
            //if(!objlist.isempty() && objlist != null){
            //rusvalue = objlist.size();
            //} else {
            rusvalue = null;
            //}
        }
        return rusvalue;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
    
    public static Set<String> generateusernames(Integer count){
        string username;
        Set<String> usernames = new Set<String>();
        for(integer i = 0; i < count; i++){
            username = generateRandomString(5) + '@' + generateRandomString(6) + '.com';
            usernames.add(username);
        }
        return usernames;
    }
    
    public static List<String> generatezipcodes(Integer count){
        List<String> zipcodes = new List<String>();
        Integer zipcode = 12345;
        string postalcode;
        for(Integer i = 0; i < count; i++){
            postalcode = String.valueOf(zipcode);
            zipcodes.add(postalcode);
            zipcode++;
        }
        return zipcodes;
    }

    public static String generateRandomNumber(Integer digits) {
        /* NOTE:  Benford’s law (also called the first digit law) states that the leading digits in a collection
          of data set are probably going to be small. For example, most numbers in a set (about 30%) will
          have a leading digit of 1, when the expected probability is 11.1% (i.e. one out of nine digits). 
        */
        String randomNumber = generate();
        String randomNumber2;
        Integer iCt = 0;
        do {
            randomNumber2 = generate();
            randomNumber = (randomNumber + randomNumber2).substring(0, digits);
            iCt += 1;
        } while (randomNumber.length() < digits && iCt < 16);
        return randomNumber;
    }
    public static String generateIdentifier(String prefix, Integer digits) {
        //usage:  Utility.generateIdentifier('DAN',5)
        return prefix + '-' + generateRandomNumber(digits);
    }

    private static String generate() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }

    /*
    public static List<Object> UniqueList(List<Object> ol) {
        //Usage:  List<Account> sl = (List<Account>)Utility.UniqueList(aList<Account>);
    	List<Object> returnList = new List<Object>();
        if (!isNullorEmpty(ol)) {
    		returnList = new List<Object>(new Set<Object>(ol));
        }
        return returnList;
    }


    public static List<SObject> UnionList(List<SObject> List1, List<SObject> List2) {
        //Usage:  List<Account> sl = (List<Account>)Utility.UnionList(aList<Account>, bList<Account>);
        //Note: This method returns a list of the UNIQUE objects that exist in EITHER List1 or List2
        List<SObject> newList = new List<Sobject>();
        if (List1 != null && List2 != null) {
        	Set<SObject> os1 = new Set<SObject>(List1);
        	Set<SObject> os2 = new Set<SObject>(List2);
            os1.addall(os2);
            newList.addall(os1);
        }
        return newList;
    }

	public static List<SObject> IntersectionList(List<SObject> List1, List<SObject> List2) {
        //Usage:  List<Account> sl = (List<Account>)Utility.IntersectionList(aList<Account>, bList<Account>);
        //Note: This method returns a list of the UNIQUE objects that exist in BOTH List1 or List2
        List<SObject> newList = new List<Sobject>();
        if (List1 != null && List2 != null) {
        	Set<SObject> os1 = new Set<SObject>(List1);
        	Set<SObject> os2 = new Set<SObject>(List2);
            for(SObject item : os1) {
                if (os2.contains(item)) {
                    newList.add(item);
                }
            }
        }
        return newList;
    }
    */

    public static List<String> fieldnames = new List<String>();

    public static Map<String, String> conditions = new Map<String, String>();

    public static List<SObject> dynamiclistquery(List<SObject> objlist, string objname, string fldname, string condition) {
        //returns a list of records found via a dynamic soql query built from the passed object and the field names and conditions utility

        integer i;
        if (fieldnames != null && !fieldnames.isempty() && fieldnames.size() > 0) {
            i = fieldnames.size();
            /*
            if (i == 5) {
                condition =
                    fieldnames[0] +
                    ' ' +
                    conditions.get(fieldnames[0]) +
                    ' and ' +
                    fieldnames[1] +
                    ' ' +
                    conditions.get(fieldnames[1]) +
                    ' and ' +
                    fieldnames[2] +
                    ' ' +
                    conditions.get(fieldnames[2]) +
                    ' and ' +
                    fieldnames[3] +
                    ' ' +
                    conditions.get(fieldnames[3]) +
                    ' and ' +
                    fieldnames[4] +
                    ' ' +
                    conditions.get(fieldnames[4]);
            } else if (i == 4) {
                condition =
                    fieldnames[0] +
                    ' ' +
                    conditions.get(fieldnames[0]) +
                    ' and ' +
                    fieldnames[1] +
                    ' ' +
                    conditions.get(fieldnames[1]) +
                    ' and ' +
                    fieldnames[2] +
                    ' ' +
                    conditions.get(fieldnames[2]) +
                    ' and ' +
                    fieldnames[3] +
                    ' ' +
                    conditions.get(fieldnames[3]);
            } else if (i == 3) {
                condition =
                    fieldnames[0] +
                    ' ' +
                    conditions.get(fieldnames[0]) +
                    ' and ' +
                    fieldnames[1] +
                    ' ' +
                    conditions.get(fieldnames[1]) +
                    ' and ' +
                    fieldnames[2] +
                    ' ' +
                    conditions.get(fieldnames[2]);
                    */
            if (i == 2) {
                condition = fieldnames[0] + ' ' + conditions.get(fieldnames[0]) + ' and ' + fieldnames[1] + ' ' + conditions.get(fieldnames[1]);
            } else if (i == 1) {
                condition = fieldnames[0] + ' ' + conditions.get(fieldnames[0]);
            }
        }

        if (condition != null) {
            string query = 'Select ' + fldname + ' from ' + objname + ' where ' + condition;
            system.debug('the query used in the dynamic query is ' + query);
            objlist = Database.query(query);
        }
        return objlist;
    }

    public static Boolean externalhierachycreated = false;

    public static Boolean processcomplete = false;

    public static string holdingcheckid = '';

    public static string holdingaccountid = '001C000001btHQgIAM';

    public static Set<String> setstrings = new Set<String>();

    public static Set<Id> returnduplicateids(Database.SaveResult res) {
        Set<Id> duplicateids = new Set<Id>();
        //string errormessage;
        Datacloud.DuplicateResult duplicateResult;
        List<Datacloud.MatchRecord> matchRecords;
        Double mc;
        Double highestmc = 0;

        for (Database.Error duplicateError : res.getErrors()) {
            //errormessage = duplicateError.getMessage();
            //system.debug('the New record create error message is ' + errormessage);
            //if(errormessage.Contains('Use one of these records')){
            duplicateResult = ((Database.DuplicateError) duplicateError).getDuplicateResult();
            //}
        }
        if (duplicateResult != null) {
            for (Datacloud.MatchResult duplicateMatchResult : duplicateResult.getMatchResults()) {
                matchRecords = duplicateMatchResult.getMatchRecords();
            }
            System.debug('total.--matchRecords--' + matchRecords);
            for (Datacloud.MatchRecord duplicateMatchRecord : matchRecords) {
                mc = duplicateMatchRecord.getMatchConfidence();
                if (mc > highestmc) {
                    highestmc = mc;
                    duplicateIds.clear();
                    duplicateIds.add(duplicateMatchRecord.getRecord().Id);
                }
            }
        }

        return duplicateids;
    }

    public static void DisplayList(List<SObject> theList) {
        integer ct = 0;
        if (theList != null && theList.isEmpty() == false) {
            String sFieldName = getNameUniqueField(theList[0].getsObjectType());
            if (sFieldName == null) {
                system.debug('DisplayList --> List does not include a Name, AutoNumber or Unique field');
                for (SObject obj : theList) {
                    ct += 1;
                    system.debug(ct + ') ' + obj.ID);
                }
            }
            try {
                for (SObject obj : theList) {
                    ct += 1;
                    system.debug(ct + ') ' + obj.ID + ' :: ' + obj.get(sFieldName));
                }
            } catch (Exception ex) {
                system.debug('DisplayList error: ' + ex.getMessage());
            }
        } else {
            if (theList == null) {
                system.debug('DisplayList: List is NULL');
            } else {
                system.debug('DisplayList: List is EMPTY');
            }
        }
    }

    public static void DisplayList(List<SObject> theList, String sFieldList) {
        integer ct = 0;
        boolean firstField = false;
        if (sFieldList == null || String.isEmpty(sFieldList)) {
            DisplayList(theList);
            return;
        }
        if (theList != null && theList.isEmpty() == false) {
            String sLine;
            List<String> fieldList = sFieldList.split(',');
            try {
                for (SObject obj : theList) {
                    ct += 1;
                    sLine = ct + ') ';
                    firstField = true;
                    for (String sFieldName : fieldList) {
                        if (firstField == true) {
                            sLine += obj.get(sFieldName.trim());
                            firstField = false;
                        } else {
                            sLine += ' :: ' + obj.get(sFieldName.trim());
                        }
                    }
                    system.debug(sLine);
                }
            } catch (Exception ex) {
                system.debug('DisplayList error: ' + ex.getMessage());
            }
        } else {
            if (theList == null) {
                system.debug('DisplayList: List is NULL');
            } else {
                system.debug('DisplayList: List is EMPTY');
            }
        }
    }

    public static String getNameUniqueField(Schema.sObjectType objType) {
        //retrieve the name, sequence or first unique field of an object
        Schema.SObjectField objField;
        DescribeFieldResult fieldDescribe;
        Schema.DescribeSObjectResult ObjResult = objType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = ObjResult.Fields.getMap();
        for (String sKey : mapFields.keySet()) {
            objField = mapFields.get(sKey);
            fieldDescribe = objField.getDescribe();
            if (fieldDescribe.isNameField()) {
                return fieldDescribe.getName();
            }
        }
        for (String sKey : mapFields.keySet()) {
            objField = mapFields.get(sKey);
            fieldDescribe = objField.getDescribe();
            if (fieldDescribe.isAutoNumber()) {
                return fieldDescribe.getName();
            }
        }
        for (String sKey : mapFields.keySet()) {
            objField = mapFields.get(sKey);
            fieldDescribe = objField.getDescribe();
            if (fieldDescribe.isUnique()) {
                return fieldDescribe.getName();
            }
        }
        return null;
    }

    /*
    public static ID getRootAccountID(ID targetID) {
        Account target = [
            SELECT
                Id,
                Hierarchy_Level__c,
                Name,
                ParentId,
                Parent.Hierarchy_Level__c,
                Parent.Name,
                Parent.ParentId,
                Parent.Parent.Hierarchy_Level__c,
                Parent.Parent.Name,
                Parent.Parent.ParentId,
                Parent.Parent.Parent.Hierarchy_Level__c,
                Parent.Parent.Parent.Name
            FROM Account
            WHERE Id = :targetID
        ];
        ID rootID;
        if (target.Hierarchy_Level__c == 0) {
            rootID = target.ID;
            //system.debug(target.name);
        } else {
            if (target.Parent.Hierarchy_Level__c == 0) {
                rootID = target.ParentID;
                //system.debug(target.parent.name);
            } else {
                if (target.Parent.Parent.Hierarchy_Level__c == 0) {
                    rootID = target.Parent.ParentID;
                    //system.debug(target.parent.parent.name);
                } else {
                    rootID = target.Parent.Parent.ParentID;
                    //system.debug(target.parent.parent.parent.name);
                }
            }
        }
        return rootID;
    }
    public static List<ID> getAccountHierarchyIDs(ID targetID) {
        List<ID> returnIDs = new List<ID>();
        Account target = [
            SELECT
                Id,
                Hierarchy_Level__c,
                Name,
                ParentId,
                Parent.Hierarchy_Level__c,
                Parent.Name,
                Parent.ParentId,
                Parent.Parent.Hierarchy_Level__c,
                Parent.Parent.Name,
                Parent.Parent.ParentId,
                Parent.Parent.Parent.Hierarchy_Level__c,
                Parent.Parent.Parent.Name
            FROM Account
            WHERE Id = :targetID
        ];
        returnIDs.add(targetID); //include the target account as first in the list
        if (target.Hierarchy_Level__c != 0) {
            //if the target account was already at root level (==0), there's nothing more to do here
            //otherwise, add the parent's ID and keep going
            returnIDs.add(target.ParentID);
            if (target.Parent.Hierarchy_Level__c != 0) {
                // if the parent account is at root level we are done
                // otherwise, add the grandparent ID
                returnIDs.add(target.Parent.ParentID);
                if (target.Parent.Parent.Hierarchy_Level__c != 0) {
                    //so there IS a great grandparent
                    returnIDs.add(target.Parent.Parent.ParentID);
                }
            }
        }
        return returnIDs;
    }

    /*
    //method to send generic emails
    //REQUIRED: TO EMAIL ADDRESS, SUBJECT, BODY (TEXTBODY OR HTMLBODY)
    //OPTIONAL: CC EMAIL ADDRESS, REPLY, DISPLAY
    public boolean sendemail(Map<String, List<String>> stringsmap) {
        Boolean emailsuccessful;
        // First, reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        Messaging.reserveSingleEmailCapacity(2);

        // Processes and actions involved in the Apex transaction occur next,
        // which conclude with sending a single email.

        // Now create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(stringsmap.get('to'));
        if (stringsmap.containskey('cc')) {
            mail.setCcAddresses(stringsmap.get('cc'));
        }
        // Specify the address used when the recipients reply to the email.
        if (stringsmap.containskey('reply')) {
            mail.setInReplyTo(stringsmap.get('reply'));
        }

        if (stringsmap.containskey('display')) {
            // Specify the name used as the display name.
            mail.setSenderDisplayName(stringsmap.get('display'));
        }

        // Specify the subject line for your email address.
        mail.setSubject(stringsmap.get('subject')[0]);

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(true);

        // Specify the text content of the email.
        if (stringsmap.containskey('textbody')) {
            mail.setPlainTextBody(stringsmap.get('textbody'));
        }

        if (stringsmap.containskey('htmlbody')) {
            mail.setHtmlBody(stringsmap.get('htmlbody'));
        }
        // Send the email you have created.
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            emailsuccessful = true;
        } catch (Exception e) {
            emailsuccessful = false;
            string errormsg = e.getMessage();
        }
        return emailsuccessful;
    }
    */
}