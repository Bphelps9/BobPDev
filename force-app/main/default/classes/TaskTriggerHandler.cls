public class TaskTriggerHandler {
    public TaskTriggerHandler() {}
    
    public void run() {
        if (Trigger.isBefore && Trigger.isInsert) {
            handlePolymorphicFieldsBeforeInsert();
        }
        else if (Trigger.isBefore && Trigger.isUpdate) {
            handlePolymorphicFieldsBeforeUpdate();
        }
    }
    
    private static void handlePolymorphicFieldsBeforeInsert() {
        List<Task> taskList = (List<Task>)Trigger.new;
        for (Task t: taskList) {
            if (t.WhatId != null) {
                ActivityPolymorphicLookupHandler.mapWhatId(t);
            }
            if (t.WhoId != null) {
                ActivityPolymorphicLookupHandler.mapWhoId(t);
            }
        }
    }
    
    private static void handlePolymorphicFieldsBeforeUpdate() {
        List<Task> taskList = (List<Task>)Trigger.new;
        Map<Id, Task> oldMap = (Map<Id, Task>)Trigger.oldMap;
        for (Task t: taskList) {
            Task oldT = oldMap.get(t.Id);
            if (t.WhatId != oldT.WhatId) {
                ActivityPolymorphicLookupHandler.mapWhatId(t);
            }
            if (t.WhoId != oldT.WhoId) {
                ActivityPolymorphicLookupHandler.mapWhoId(t);
            }
        }
    }
}