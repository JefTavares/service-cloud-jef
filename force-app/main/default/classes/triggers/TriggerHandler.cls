/**
 * @description       : Interface para os triggers, toda os métodos das triggers devem ser implementadas nesta interface
 * @author            : Jeferson Tavares
 * @group             :
 * @last modified on  : 12-13-2024
 * @last modified by  : Jeferson Tavares
 **/

public interface TriggerHandler {
    void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap);

    void afterInsert(List<SObject> newRecords, Map<Id, SObject> newRecordMap);

    void afterUndelete(List<SObject> newRecords, Map<Id, SObject> newRecordMap);

    void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap);

    void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldRecordMap);

    void beforeInsert(List<SObject> newRecords);

    void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<Id, SObject> oldRecordMap, Map<Id, SObject> newRecordMap);

}