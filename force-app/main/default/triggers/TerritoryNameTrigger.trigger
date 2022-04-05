trigger TerritoryNameTrigger on TerritoryName__c (before insert, before update, after insert, after update) {
    
    TerritoryName_h tnh = new TerritoryName_h();
    
    if(trigger.isBefore && trigger.isInsert){
        tnh.beforeInsert(trigger.new);
    } else if(trigger.isAfter && trigger.isInsert){
        tnh.afterInsert(trigger.new);
    } else if(trigger.isBefore && trigger.isUpdate){
        tnh.beforeUpdate(trigger.new, trigger.oldMap);
    }  else if(trigger.isAfter && trigger.isUpdate){
        tnh.afterUpdate(trigger.new, trigger.oldMap);
    }

}