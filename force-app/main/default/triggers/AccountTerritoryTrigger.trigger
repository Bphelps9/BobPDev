trigger AccountTerritoryTrigger on Account (before insert, before update, after update) {
    System.debug('trigger');
    new AccountTriggerHandler().run();
    If(Trigger.isupdate && Trigger.isbefore)
    {
        list<String> accIds = new  list<String>();
        Map<Id,Integer> mapOfContacts = new Map<id,Integer>();
        Map<Id,Integer> mapOfCases = new Map<id,Integer>();
        Map<Id,Integer> mapOfTasks = new Map<id,Integer>();
        Map<Id,Integer> mapOfEvents = new Map<id,Integer>();
        Map<Id,Integer> mapOfNotes = new Map<id,Integer>();
        Map<Id,Integer> mapOfFiles = new Map<id,Integer>();
        Map<Id,Integer> mapOfContracts = new Map<id,Integer>();
        Map<Id,Integer> mapOShipto = new Map<id,Integer>();
        Map<Id,Integer> mapOfBillTo = new Map<id,Integer>();
        Map<Id,Integer> mapOfDestination = new Map<id,Integer>();
        for(Account acc:Trigger.new)
        {
            accIds.add(acc.Id);
        }
        list<AggregateResult> agrs = [SELECT count(id) Ct,AccountId FROM Contact WHERE AccountId in :accIds GROUP BY AccountId];
        list<AggregateResult> agrs1 = [SELECT count(id) Ct,AccountId FROM Case WHERE AccountId in :accIds GROUP BY AccountId];
        list<AggregateResult> agrs2 = [SELECT count(id) Ct,AccountId FROM Task WHERE AccountId in :accIds GROUP BY AccountId];
        list<AggregateResult> agrs3 = [SELECT count(id) Ct,AccountId FROM Event WHERE AccountId in :accIds GROUP BY AccountId];
        list<AggregateResult> agrs4 = [SELECT count(id) Ct,LinkedEntityId  FROM ContentDocumentLink  WHERE LinkedEntityId  in :accIds AND ContentDocument.FileType='SNOTE' GROUP BY LinkedEntityId ];
        list<AggregateResult> agrs5 = [SELECT count(id) Ct,LinkedEntityId  FROM ContentDocumentLink  WHERE LinkedEntityId  in :accIds AND ContentDocument.FileType!='SNOTE' GROUP BY LinkedEntityId ];
        list<AggregateResult> agrs6 = [SELECT count(id) Ct,AccountId  FROM Contract  WHERE AccountId  in :accIds GROUP BY AccountId ];
        list<AggregateResult> agrs7 = [SELECT count(id) Ct,Ship_To__c FROM Opportunity WHERE Ship_To__c in :accIds GROUP BY Ship_To__c];
        list<AggregateResult> agrs8 = [SELECT count(id) Ct,Bill_To__c FROM Opportunity WHERE Bill_To__c in :accIds GROUP BY Bill_To__c];
        list<AggregateResult> agrs9 = [SELECT count(id) Ct,Destination__c FROM Opportunity WHERE Destination__c in :accIds GROUP BY Destination__c];
        for(AggregateResult agr:agrs)
        {
            String AccountId = String.valueOf(agr.get('AccountId'));
            Integer count = Integer.valueOf(agr.get('Ct'));
            mapOfContacts.put(AccountId,count);
        }
         for(AggregateResult agr:agrs1)
        {
            String AccountId = String.valueOf(agr.get('AccountId'));
            Integer count = Integer.valueOf(agr.get('Ct'));
            mapOfCases.put(AccountId,count);
        }
          for(AggregateResult agr:agrs2)
        {
            String AccountId = String.valueOf(agr.get('AccountId'));
            Integer count = Integer.valueOf(agr.get('Ct'));
            mapOfTasks.put(AccountId,count);
        }
          for(AggregateResult agr:agrs3)
        {
            String AccountId = String.valueOf(agr.get('AccountId'));
            Integer count = Integer.valueOf(agr.get('Ct'));
            mapOfEvents.put(AccountId,count);
        }
         for(AggregateResult agr:agrs4)
        {
            String AccountId = String.valueOf(agr.get('LinkedEntityId'));
            Integer count = Integer.valueOf(agr.get('Ct'));  mapOfNotes.put(AccountId,count);
        }
         for(AggregateResult agr:agrs5)
        {
            String AccountId = String.valueOf(agr.get('LinkedEntityId'));
            Integer count = Integer.valueOf(agr.get('Ct'));  mapOfFiles.put(AccountId,count);
        }
         for(AggregateResult agr:agrs6)
        {
            String AccountId = String.valueOf(agr.get('AccountId'));
            Integer count = Integer.valueOf(agr.get('Ct'));  mapOfContracts.put(AccountId,count);
        }
        for(AggregateResult agr:agrs7)
        {
            String AccountId = String.valueOf(agr.get('Ship_To__c'));
            Integer count = Integer.valueOf(agr.get('Ct'));  mapOShipto.put(AccountId,count);
        }
        for(AggregateResult agr:agrs8)
        {
            String AccountId = String.valueOf(agr.get('Bill_To__c'));
            Integer count = Integer.valueOf(agr.get('Ct'));  mapOfBillTo.put(AccountId,count);
        }
        for(AggregateResult agr:agrs9)
        {
            String AccountId = String.valueOf(agr.get('Destination__c'));
            Integer count = Integer.valueOf(agr.get('Ct'));  mapOfDestination.put(AccountId,count);
        }
        for(Account acc:Trigger.new)
        {
             if(mapOfDestination.keySet().contains(acc.Id))
            {
                acc.Destination_Number__c = mapOfDestination.get(acc.Id);
            }
             if(mapOfBillTo.keySet().contains(acc.Id))
            {
                acc.Bill_To_Number__c = mapOfBillTo.get(acc.Id);
            }
            if(mapOShipto.keySet().contains(acc.Id))
            {
                acc.Ship_to_Number__c = mapOShipto.get(acc.Id);
            }
            if(mapOfContacts.keySet().contains(acc.Id))
            {
                acc.Number_Of_Contacts__c = mapOfContacts.get(acc.Id);
            }
            if(mapOfCases.keySet().contains(acc.Id))
            {
                acc.Number_Of_Cases__c = mapOfCases.get(acc.Id);
            }
             if(mapOfTasks.keySet().contains(acc.Id))
            {
                acc.Number_Of_Tasks__c = mapOfTasks.get(acc.Id);
            }
             if(mapOfEvents.keySet().contains(acc.Id)) 
            {
                acc.Number_Of_Events__c = mapOfEvents.get(acc.Id); 
            }
             if(mapOfNotes.keySet().contains(acc.Id))  { acc.Number_Of_Notes__c = mapOfNotes.get(acc.Id);    }
            if(mapOfFiles.keySet().contains(acc.Id))   {        acc.Number_Of_Files__c = mapOfFiles.get(acc.Id);         }
            if(mapOfContracts.keySet().contains(acc.Id))   {        acc.Number_Of_Contracts__c = mapOfContracts.get(acc.Id);         }
            
        }
        
        
    }
}