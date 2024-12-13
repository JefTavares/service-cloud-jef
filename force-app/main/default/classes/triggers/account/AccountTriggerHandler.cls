/**
 * @description       :
 * @author            : Jeferson Tavares
 * @group             :
 * @last modified on  : 12-13-2024
 * @last modified by  : Jeferson Tavares
 **/

public class AccountTriggerHandler implements TriggerHandler {

    private final Boolean triggerIsExecuting;
    private final Integer triggerSize;
    public AccountTriggerHelper helper;

    public AccountTriggerHandler(Boolean triggerIsExecuting, Integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new AccountTriggerHelper();
    }

    public void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap) {
    }

    public void afterInsert(List<SObject> newRecords, Map<Id, SObject> newRecordMap) {
    }

    public void afterUndelete(List<SObject> newRecords, Map<Id, SObject> newRecordMap) {
    }

    public void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap) {
    }

    public void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap) {
    }

    public void beforeInsert(List<SObject> newRecords) {
    }

    public void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap) {
    }
}