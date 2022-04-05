/*
 * Since the data model and the naming conventions of the Territory Names and Territory IDs are very confusing
 * there's a thorough explaination of what's happening in the code below for anyone picking this up later. Took me hours to figure this out. Good luck!
 * 
 * Territory_ID__c - contains mappings of Zip Codes (Zip_Code__c) to unique Territory IDs (Name). These territoriy IDs are then used to match with the Territory_Name__c records.
 * TerritoryName__c - represents the salespeople (Name__c), their Positions (Position__c) and territory belonging by unique territory ID (Territory_ID__c).
*/

public class TerritoryAssignmentHandler {

    // ID of the default territory
    private final String defaultTerritoryNumber = null;
    // ID of the special AMETEK Territory
    private final String ametekTerritoryNumber = null;
    // ID of the special SFD Territory
    private final String sfdTerritoryNumber = null;
    // If no territory corresponding to the zipcode is found, this default territory is used for assignment
    private final TerritoryStruct defaultTerritory = new TerritoryStruct();
    // Ametek Territory record
    private final TerritoryStruct ametekTerritory = new TerritoryStruct();
    // SFD Territory record
    private final TerritoryStruct sfdTerritory = new TerritoryStruct();
    
    // Map with unique ZipCode set as key and territory details set as value
    private final Map<String, TerritoryStruct> territoryMap = new Map<String, TerritoryStruct>();
    // 
    private final Map<String, TerritoryStruct> idTerritoryMap = new Map<String, TerritoryStruct>();
	// IDs of records that are overriden mapped against the IDs (numbers) of overriding territories
	private final Map<Id, String> recordOverrideMap = new Map<Id, String>();


    // 
    private final List<String> specialTerritoryNumbers;

    /**
     * @description A custom class/struct for storing territory details
     */
    public class TerritoryStruct {
        /**
         * @description Unique ID of the territory. Example: 32, 95, 155
         */
        public String territoryNumber;
        /**
         * @description ID of the Account Manager's Territory Name record. Example: a665y0000000Ab3
         */
        public Id territoryId;
        /*
         * @description Account Manager's name. Example: John Johnson
         */
        public String am;
        /*
         *  @description User ID of the Account Mananger.
         */
        public Id amId;
        /*
         * @description Program Consultant's name. Example: Jack Jackson
         */
        public String pc;
        /*
         *  @description User ID of the Program Consultant.
         */
        public Id pcId;
        /*
         * @description Regional Vice President's name. Example: Steven Stevenson
         */
        public String rvp;
        /*
         *  @description User ID of the Regional Vice President
         */
        public Id rvpId;
        /**
         * @escription State of the Territory ID object
         */
        public String state;
        /**
         * @escription County of the Territory ID object
         */
        public String county;
    }

    public TerritoryAssignmentHandler(Set<String> postalCodes, String objectApiName, Map<Id, String> overrideMap) {
        // Find the default territory number
        specialTerritoryNumbers = fetchDefaultTerritoryNumbers(objectApiName);
        this.defaultTerritoryNumber = specialTerritoryNumbers[0];
        this.ametekTerritoryNumber = specialTerritoryNumbers[1];
        this.sfdTerritoryNumber = specialTerritoryNumbers[2];
        this.defaultTerritory.territoryNumber = this.defaultTerritoryNumber;
        this.ametekTerritory.territoryNumber = this.ametekTerritoryNumber;
        this.sfdTerritory.territoryNumber = this.sfdTerritoryNumber;
        if (overrideMap != null) {
            this.recordOverrideMap.putAll(overrideMap);
        }
        // Get all territory details for given zipcodes
        fetchTerritoryDetailsByPostalCode(postalCodes);
    }

    /**
     * @description Get the Territory details for given zipcode
     * @param 
     * @param postalCode Zip code to retrieve the territory by
     * @param specialType
     * @return TerritoryStruct instance corresponding to postal code, or default TerritoryStruct
     */
    public TerritoryStruct getTerritoryDetails(Id recordId, String postalCode, String specialType) {
        if (recordOverrideMap.containsKey(recordId)) {
            String terNumber = recordOverrideMap.get(recordId);
            TerritoryStruct str = idTerritoryMap.get(terNumber);
            if (str != null) {
                return str;
            }
        }
        if (!String.isBlank(postalCode)) {
            if (!String.isBlank(specialType)) {
                switch on specialType {
                    when 'AMETEK' {
                        if (ametekTerritory.territoryNumber != null) {
                            return ametekTerritory;
                        }
                    }
                    when 'School for the Deaf' {
                        if (sfdTerritory.territoryNumber != null) {
                            return sfdTerritory;
                        }
                    }
                }
            }
            // Some postal codes may contain additional values appended after dash, which should be ignored
            String formattedCode = postalCode.left(5);
            TerritoryStruct str = territoryMap.get(formattedCode);
            if (str != null) {
                return str;
            }
        }
        return defaultTerritory;
    }

    private List<String> fetchDefaultTerritoryNumbers(String objectApiName) {
        List<Territory_Assignment_Setting__mdt> settings = [SELECT Id, Default_Territory_ID__c, AMETEK_Territory_ID__c, SFD_Territory_ID__c FROM Territory_Assignment_Setting__mdt WHERE Object_API_Name__c = :objectApiName];
        List<String> ids = new List<String>();
        if (!settings.isEmpty()) {
            Territory_Assignment_Setting__mdt setting = settings[0];
            ids.add(setting.Default_Territory_ID__c);
            ids.add(setting.AMETEK_Territory_ID__c);
            ids.add(setting.SFD_Territory_ID__c);
        } else {
            for (Integer i = 0; i < 3; i++) {
                ids.add(null);
            }
        }
        return ids;
    }
    
    /**
     * @description Retrieve the map of Territory and Sales Position details for given by Postal Codes
     * @param postalCodes Set of unique Postal Codes
     * @return Territory details mapped against their corresponding zip code values
     */
    private void fetchTerritoryDetailsByPostalCode(Set<String> postalCodes) {
        // Some postal codes may contain additional values appended after dash, which should be ignored
        Set<String> formattedPostalCodes = new Set<String>();
        for (String code: postalCodes) {
            if (!String.isBlank(code)) {
            	formattedPostalCodes.add(code.left(5));
            }
        }
        // Territory IDs that override Territory rules on certain Accounts
        Set<String> overridenTerNums = new Set<String>(this.recordOverrideMap.values());
        // Collect all Territory ID/ZipCode mappings for the provided postal codes. It is expected that the a postal code is only mapped to a single Territory ID
        List<Territory_ID__c> territoryIdRecords = [SELECT Id, Name, Zip_Code__c, County__c, StateAbbr__c FROM Territory_ID__c WHERE Zip_Code__c IN :formattedPostalCodes OR Name IN :overridenTerNums];
        // Create Territory struct instances, store the unique territory ID and map against the zip code
        // Collect zip codes mapped against their corresponding Territory ID
        Map<String, Set<String>> territoryZipMap = new Map<String, Set<String>>();
        for (Territory_ID__c terrIdRecord: territoryIdRecords) {
            TerritoryStruct struct = new TerritoryStruct();
            struct.territoryNumber = terrIdRecord.Name;
            struct.state = terrIdRecord.StateAbbr__c;
            struct.county = terrIdRecord.County__c;
            territoryMap.put(terrIdRecord.Zip_Code__c, struct);
            idTerritoryMap.put(terrIdRecord.Name, struct);
            Set<String> zipCodes = territoryZipMap.get(terrIdRecord.Name);
            if (zipCodes == null) {
                zipCodes = new Set<String>();
                territoryZipMap.put(terrIdRecord.Name, zipCodes);
            }
            zipCodes.add(terrIdRecord.Zip_Code__c);
        }
        for (String territoryNum: specialTerritoryNumbers) {
            if (territoryNum != null && !territoryZipMap.containsKey(territoryNum)) {
                territoryZipMap.put(territoryNum, null);
            }
        }
		// Retrieve salespeople details by collected Territory IDs. It is expected that a unique Territory ID will have only one type of each position pair
        List<TerritoryName__c> territoryPositions = [SELECT Id, Name, Territory_ID__c, Position__c, Name__c, User__c FROM TerritoryName__c WHERE Territory_ID__c IN :territoryZipMap.keySet()];
        for (TerritoryName__c position: territoryPositions) {
            if (position.Territory_ID__c == defaultTerritoryNumber) {
                populatePositions(position, defaultTerritory);
            } else if (position.Territory_ID__c == ametekTerritoryNumber) {
                populatePositions(position, ametekTerritory);
            } else if (position.Territory_ID__c == sfdTerritoryNumber) {
                populatePositions(position, sfdTerritory);
            }
            // Retrieve the Territory struct by unique Territory ID
	        Set<String> zipCodes = territoryZipMap.get(position.Territory_ID__c);
            if (zipCodes != null) {
                for (String z :zipCodes) {
                    populatePositions(position, territoryMap.get(z));
                }
            }
        }
    }

    private void populatePositions(TerritoryName__c position, TerritoryStruct ter) {
        if (ter != null) {
            // Determine the position and set to the corresponding parameter in struct
            if (position.Position__c.contains('Account Manager') || position.Position__c.contains('Field Based Project Manager')) {
                ter.am = position.Name__c;
                ter.amId = position.User__c;
                ter.territoryId = position.Id;
            }
            else if (position.Position__c.contains('Program Consultant') || position.Position__c.contains('Sales Operations Manager')) {
                ter.pc = position.Name__c;
                ter.pcId = position.User__c;
            }
            else if (position.Position__c.contains('Regional VP')) {
                ter.rvp = position.Name__c;
                ter.rvpId = position.User__c;
            }
        }
    }
}