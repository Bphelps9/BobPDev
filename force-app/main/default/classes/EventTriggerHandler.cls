public class EventTriggerHandler {
    public EventTriggerHandler() {}
    
    public void run() {
        if (Trigger.isBefore && Trigger.isInsert) {
            handlePolymorphicFieldsBeforeInsert();
        }
        else if (Trigger.isBefore && Trigger.isUpdate) {
            handlePolymorphicFieldsBeforeUpdate();
        }
    }
    
    private static void handlePolymorphicFieldsBeforeInsert() {
        List<Event> eventList = (List<Event>)Trigger.new;
        for (Event e: eventList) {
            if (e.WhatId != null) {
            	ActivityPolymorphicLookupHandler.mapWhatId(e);
            }
            if (e.WhoId != null) {
            	ActivityPolymorphicLookupHandler.mapWhoId(e);
            }
        }
    }
    
    private static void handlePolymorphicFieldsBeforeUpdate() {
        List<Event> eventList = (List<Event>)Trigger.new;
        Map<Id, Event> oldMap = (Map<Id, Event>)Trigger.oldMap;
        for (Event e: eventList) {
            Event oldE = oldMap.get(e.Id);
            if (e.WhatId != oldE.WhatId) {
                ActivityPolymorphicLookupHandler.mapWhatId(e);
            }
            if (e.WhoId != oldE.WhoId) {
            	ActivityPolymorphicLookupHandler.mapWhoId(e);
            }
        }
    }
}