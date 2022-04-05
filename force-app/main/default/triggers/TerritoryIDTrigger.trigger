trigger TerritoryIDTrigger on Territory_ID__c (before insert, before update, after insert, after update) {
    
    TerritoryID_h tidh = new TerritoryID_h();
    
    if(trigger.isBefore && trigger.isInsert){
        tidh.beforeInsert(trigger.new);
    } else if(trigger.isAfter && trigger.isInsert){
        tidh.afterInsert(trigger.new);
    } else if(trigger.isBefore && trigger.isUpdate){
        tidh.beforeUpdate(trigger.new, trigger.oldMap);
    }  else if(trigger.isAfter && trigger.isUpdate){
        tidh.afterUpdate(trigger.new, trigger.oldMap);
    }

}