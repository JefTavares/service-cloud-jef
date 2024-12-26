/**
 * @description : Controller do componente datatable, responsável por chamar as apis e mais
 * @author : Jeferson Tavares - EX300265
 * Created by EX300265 on 28/10/2024.
 */

public with sharing class ComponentViewController {

    // Retorna os dados de api
    @AuraEnabled
    public static Map<String, String> getRecords(String dataString) {
        System.debug('1 - getRecords: ' + dataString);
        DataWrapper dataWrapper = (DataWrapper) JSON.deserialize(dataString, DataWrapper.class); //todo Incluir na classe pensando em um this.dataWrapper
        Map<String, String> mapToReturn = getDataFromAPI(dataWrapper);

        List<RecordType> caseRecordTypes = getRecordsTypes();
        mapToReturn.put('RecordTypes', JSON.serialize(caseRecordTypes));

        return mapToReturn;
    }

    public static Map<String, String> getDataFromAPI(DataWrapper dataWrapper) {
        Map<String, String> mapToReturn = new Map<String, String>();
        System.debug('2 - getDataFromAPI dataWrapper >>>' + dataWrapper);
        //Busca parametrização das API
        ComponentView__mdt componentList = getComponentMetadata(dataWrapper.metadataName);
        System.debug('getDataFromAPI componentList >>>' + componentList);
        TableResponseWrapper tableToReturn = getTableResponse(componentList);
        System.debug('getDataFromAPI tableToReturn >>>' + tableToReturn);

        //busca dados do objeto corrente dataWrapper.recordId que foi passado na chamada da classe lá no getRecords(String dataString)
        //Exemplo para pegar a conta do cliente, busca o cpf para ser utilizado nas chamadas de API
        SObject sObj = getSObject(dataWrapper);
        System.debug('getDataFromAPI getSobject>>>' + sObj);

        mapToReturn.put('Columns', JSON.serialize(tableToReturn.tableColumns));

        //TODO Mudar para switch case
        if (componentList.DeveloperName == 'Afinidades') {
            System.debug('getDataFromAPI - componentList.DeveloperName >>>' + componentList.DeveloperName);
            //TODO Incluir essa linha a de baixo é para testes
            //AffinitySinDTO.AffinitySinResponse affinity = AffinityService.searchPolicieByDocumentName('01185631143', 'Mayara');
            AffinitySinDTO.AffinitySinResponse affinity = AffinityService.searchPolicieByDocumentName(String.valueOf(sObj.get('CPF_CNPJ__c')), String.valueOf(sObj.get('Name')));
            System.debug('getDataFromAPI - affinity >>>' + affinity);
            mapToReturn.put('Affinity', JSON.serialize(affinity));
        }

        return mapToReturn;
    }

    public static ComponentView__mdt getComponentMetadata(String metadataName) {
        System.debug('5 - getComponentMetadata: ' + metadataName);
        return [SELECT Id, DeveloperName, MasterLabel, ColumnHeader__c, FieldAndType__c, ApiFieldsTypesAndCaseFields__c, ApiFieldsTypesAndOppFields__c FROM ComponentView__mdt WHERE DeveloperName = :metadataName];
    }

    //Retorna um SObject dinâmico a partir de um recordId
    public static SObject getSObject(DataWrapper dataWrapper) {
        System.debug('4 - getSObject: ' + dataWrapper);
        String fieldsToSOQL = mapFieldsToSOQL(dataWrapper.objectApiName);
        String soql = 'SELECT ' + fieldsToSOQL + ' FROM ' + dataWrapper.objectApiName + ' WHERE Id =\'' + dataWrapper.recordId + '\'';
        System.debug('getSObject - soql >>>>' + soql);
        return Database.query(soql);
    }

    //Campos que devem ser retornados na consulta SOQL
    public static String mapFieldsToSOQL(String objectApiName) {
        //Pega todos os campos de um objeto
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
        String fieldsToSOQL = '';
        for (String fieldName : fieldsMap.keySet()) {
            fieldsToSOQL = fieldsToSOQL == '' ? fieldName : fieldsToSOQL + ', ' + fieldName;
        }
        System.debug('mapFieldsToSOQL>>>' + fieldsToSOQL);
        return fieldsToSOQL;
    }

    //Com base no metadado ComponentView. Cria um objeto que define toda a estrutura da integração
    //Label do campo, nome do campo na api, tipo do campo Exemplo: ColumnWrapper:[fieldName=status, label=Status, type=text]
    public static TableResponseWrapper getTableResponse(ComponentView__mdt metadata) {
        System.debug('3 - getTableResponse: ' + metadata);
        List<String> columnHeaderList = new List<String>();
        List<String> columnFieldTypeList = new List<String>();
        List<ColumnWrapper> columnsList = new List<ColumnWrapper>();

        //Pega os header do metadados - Ou label da grid
        if (metadata.ColumnHeader__c != null) {
            columnHeaderList = metadata.ColumnHeader__c.split(', ');
        }
        //Pega o api e tipo dos campos
        if (metadata.FieldAndType__c != null) {
            columnFieldTypeList = metadata.FieldAndType__c.split(', ');
        }

        for (Integer i = 0; i < columnHeaderList.size(); i++) {
            System.debug(columnHeaderList[i].trim()); //Label da Coluna na grid
            System.debug(columnFieldTypeList[i].substringBefore(':').trim()); //Nome do campo na API
            System.debug(columnFieldTypeList[i].substringAfter(':').trim()); // Tupo de dado
            ColumnWrapper tableColumn = new ColumnWrapper(columnHeaderList[i].trim(), columnFieldTypeList[i].substringBefore(':').trim(), columnFieldTypeList[i].substringAfter(':').trim());
            columnsList.add(tableColumn);
        }

        TableResponseWrapper tableToReturn = new TableResponseWrapper();
        tableToReturn.tableColumns = columnsList;
        System.debug('getTableResponse >>>' + tableToReturn);
        return tableToReturn;

    }

    public static List<RecordType> getRecordsTypes() {
        Set<String> idsRecordType = new Set<String>();
        for (RecordTypeInfo tipoDeRegistro : Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (tipoDeRegistro.isAvailable() && !tipoDeRegistro.isMaster() && tipoDeRegistro.isActive() && tipoDeRegistro.getName() != 'Email To Case') {
                idsRecordType.add(tipoDeRegistro.getRecordTypeId());
            }
        }
        return [SELECT Id, Name, DeveloperName, Description FROM RecordType WHERE Id IN :idsRecordType];
    }


    @AuraEnabled
    public static Map<String, String> createRecord(String objString) {
        Map<String, String> mapToReturn = new Map<String, String>();
        ObjWrapper objWrapper = (ObjWrapper) JSON.deserialize(objString, ObjWrapper.class);
        SObject sObj = setObjValues(objWrapper);
        mapToReturn.put('SObject', JSON.serialize(sObj));
        System.debug('objWrapper >>>' + objWrapper);
        return mapToReturn;
    }

    public static SObject setObjValues(ObjWrapper objWrapper) {
        SObject sObj = Schema.getGlobalDescribe().get(objWrapper.objectApiName).newSObject() ;
        Map<String, ObjFieldWrapper> retrieveObjField = new Map<String, ObjFieldWrapper>();
        List<ObjFieldWrapper> objFieldList = setObjFieldWrapper(objWrapper);

        for (ObjFieldWrapper objField : objFieldList) {
            retrieveObjField.put(objField.fieldApi, objField);
        }
        System.debug('retrieveObjField >>>' + retrieveObjField);


        for (FieldWrapper fieldWrapper : objWrapper.fields) {
            System.debug('objWrapper.fields >>>' + objWrapper.fields);

            ObjFieldWrapper objField = retrieveObjField.get(fieldWrapper.apiName);

            if (objField != null && fieldWrapper.value != '') {
                switch on objField.type {
                    when 'text', 'PICKLIST', 'MULTIPICKLIST' {
                        sObj.put(objField.fieldCaseApiName, fieldWrapper.value);
                    }
                    when 'BOOLEAN', 'checkbox' {
                        sObj.put(objField.fieldCaseApiName, Boolean.valueOf(fieldWrapper.value));
                    }
                    when 'date' {
                        sObj.put(objField.fieldCaseApiName, Date.valueOf(fieldWrapper.value));
                    }
                    when 'datetime' {
                        String dtString = fieldWrapper.value.substringBefore('T');
                        sObj.put(objField.fieldCaseApiName, Date.valueOf(dtString));
                    }
                    when 'number' {
                        System.debug('Valor fail >>' + fieldWrapper.value);
                        if (fieldWrapper.value == '0.0') {
                            sObj.put(objField.fieldCaseApiName, Double.valueOf('0'));
                        } else {
                            sObj.put(objField.fieldCaseApiName, Double.valueOf(fieldWrapper.value));
                        }
                    }
                    when else {
                        sObj.put(objField.fieldCaseApiName, fieldWrapper.value);
                    }
                }
            }
        }

        populateFixedValues(sObj, objWrapper);

        if (sObj != null) {
            insert sObj;
        }
        System.debug('sObj: ' + sObj);

        return sObj;
    }

    public static List<ObjFieldWrapper> setObjFieldWrapper(ObjWrapper objWrapper) {
        ComponentView__mdt metadata = getComponentMetadata(objWrapper.metadataName);
        List<String> columnFieldTypeList = new List<String>();
        List<ObjFieldWrapper> objFieldList = new List<ObjFieldWrapper>();

        if (objWrapper.objectApiName == 'Case') {
            if (metadata.ApiFieldsTypesAndCaseFields__c != null) {
                columnFieldTypeList = metadata.ApiFieldsTypesAndCaseFields__c.split(', ');
            }
        }
        if (objWrapper.objectApiName == 'Opportunity') {
            if (metadata.ApiFieldsTypesAndOppFields__c != null) {
                columnFieldTypeList = metadata.ApiFieldsTypesAndOppFields__c.split(', ');
            }
        }

        for (Integer i = 0; i < columnFieldTypeList.size(); i++) {
            ObjFieldWrapper ObjFieldWrapper = new ObjFieldWrapper(columnFieldTypeList[i].substringBefore(':').trim(), columnFieldTypeList[i].substringBetween(':').trim(), columnFieldTypeList[i].substringAfterLast(':').trim());
            objFieldList.add(ObjFieldWrapper);
        }

        return objFieldList;
    }

    private static void populateFixedValues(SObject sObj, ObjWrapper objWrapper) {
        setFieldValueMap(sObj, objWrapper.objectApiName, 'Classificacao_Negocio__c', objWrapper.metadataName);
        setFieldValueMap(sObj, objWrapper.objectApiName, 'AccountId', objWrapper.recordId);

        if (objWrapper.objectApiName == 'Case') {
            setCaseFields(sObj, objWrapper);
        }

        if (objWrapper.objectApiName == 'Opportunity') {
            setOpportunityFields(sObj, objWrapper);
        }
    }

    private static void setFieldValueMap(SObject sObj, String objectApiName, String fieldApi, String value) {
        System.debug(fieldApi);
        String nameField = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApi).getDescribe().getName();
        sObj.put(nameField, value);
    }

    private static void setCaseFields(SObject sObj, ObjWrapper objWrapper) {

        setFieldValueMap(sObj, objWrapper.objectApiName, 'RecordTypeId', objWrapper.recordTypeId);
        setFieldValueMap(sObj, objWrapper.objectApiName, 'Corretor__c', 'Caixa Seguridade Corretagem e Administração de Seguros S.A');

        if (objWrapper.recordTypeId == getRecordTypeId(objWrapper.objectApiName, 'areas_internas')) {
            setFieldValueMap(sObj, objWrapper.objectApiName, 'Status_Desligamento__c', 'Em analise');
        }

        if (objWrapper.metadataName == 'Afinidades') {
            setFieldValueMap(sObj, objWrapper.objectApiName, 'Produto_Susep__c', 'Habitacional');
        }
    }

    private static void setOpportunityFields(SObject sObj, ObjWrapper objWrapper) {

        objWrapper.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Oportunidade_Padrao').getRecordTypeId();
        setFieldValueMap(sObj, objWrapper.objectApiName, 'RecordTypeId', objWrapper.recordTypeId);
        setFieldValueMap(sObj, objWrapper.objectApiName, 'Name', '.');
    }

    private static Id getRecordTypeId(String objectApiName, String recordTypeName) {
        return Schema.getGlobalDescribe().get(objectApiName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    }

    //Dados recebidos pela funcionalidade geral
    public class DataWrapper {
        @AuraEnabled
        public String metadataName;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String cpfCnpj;
        @AuraEnabled
        public String nomeSegurado;
    }

    public class ObjWrapper {
        @AuraEnabled
        public List<FieldWrapper> fields;
        @AuraEnabled
        public String metadataName;
        @AuraEnabled
        public String recordTypeId;
        @AuraEnabled
        public String recordTypeName;
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String objectApiName;

        public ObjWrapper() {
            this.fields = new List<FieldWrapper>();
        }
    }

    public class FieldWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public List<FieldWrapper> listValues;

        public FieldWrapper() {
            this.listValues = new List<FieldWrapper>();
        }
    }

    public class ObjFieldWrapper {
        @AuraEnabled
        public String fieldApi { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String fieldCaseApiName { get; set; }

        public ObjFieldWrapper(String fieldApi, String type, String fieldCaseApiName) {
            this.fieldApi = fieldApi;
            this.type = type;
            this.fieldCaseApiName = fieldCaseApiName;
        }
    }

    //Colunas do metadado mapeado
    public class ColumnWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }

        //Construtor que monta um novo ColumnWrapper
        public ColumnWrapper(String label, String fieldName, String type) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
        }
    }

    //Definição da tabela
    public class TableResponseWrapper {
        @AuraEnabled
        public List<ColumnWrapper> tableColumns { get; set; }
    }
}