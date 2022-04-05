trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    
    Account_h ath = new Account_h();
    
    if(trigger.isBefore && trigger.isInsert){
        ath.beforeInsert(trigger.new);
    } else if(trigger.isAfter && trigger.isInsert){
        ath.afterInsert(trigger.new);
    } else if(trigger.isBefore && trigger.isUpdate){
        ath.beforeUpdate(trigger.new, trigger.oldMap);
    }  else if(trigger.isAfter && trigger.isUpdate){
        ath.afterUpdate(trigger.new, trigger.oldMap);
    }

}