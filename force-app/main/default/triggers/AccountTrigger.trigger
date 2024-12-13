/**
 * Created by EX300265 on 13/12/2024.
 */

trigger AccountTrigger on Account (before insert, after update) {
    System.debug('Trigger.isExecuting:' + Trigger.isExecuting);
    System.debug('Trigger.size:' + Trigger.size);
    TriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when BEFORE_DELETE {
            handler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_INSERT {
            handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            System.debug('Trigger.old:' + Trigger.old);
            System.debug('Trigger.new:' + Trigger.new);
            System.debug('Trigger.oldMap:' + Trigger.oldMap);
            System.debug('Trigger.newMap:' + Trigger.newMap);

            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
            handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}