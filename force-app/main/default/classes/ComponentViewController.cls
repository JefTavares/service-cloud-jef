/**
 * @description : Controller do componente datatable, responsável por chamar as apis e mais
 * @author : Jeferson Tavares - EX300265
 * Created by EX300265 on 28/10/2024.
 */

public with sharing class ComponentViewController {

    // Retorna os dados de api
    public static Map<String, String> getRecords(String dataString) {
        System.debug('1 - getRecords: ' + dataString);
        DataWrapper dataWrapper = (DataWrapper) JSON.deserialize(dataString, DataWrapper.class); //todo Incluir na classe pensando em um this.dataWrapper
        Map<String, String> mapToReturn = getDataFromAPI(dataWrapper);

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
            //TODO Incluir essa linha a de baixo é para testes AffinitySinDTO.AffinitySinResponse affinity = AffinityService.searchPolicieByDocumentName(String.valueOf(sObj.get('CPF_CNPJ__c')), String.valueOf(sObj.get('Name')));
            AffinitySinDTO.AffinitySinResponse affinity = AffinityService.searchPolicieByDocumentName('32729267808', 'JefersonT');
            System.debug('getDataFromAPI - affinity >>>' + affinity);
            //mapToReturn.put('Affinity', JSON.serialize(affinity));
        }

        return mapToReturn;
    }

    public static ComponentView__mdt getComponentMetadata(String metadataName) {
        return [SELECT Id, DeveloperName, MasterLabel, ColumnHeader__c, FieldAndType__c, ApiFieldsTypesAndCaseFields__c, ApiFieldsTypesAndOppFields__c FROM ComponentView__mdt WHERE DeveloperName = :metadataName];
    }

    public static SObject getSObject(DataWrapper dataWrapper) {
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
            System.debug(columnHeaderList[i].trim());
            System.debug(columnFieldTypeList[i].substringBefore(':').trim());
            System.debug(columnFieldTypeList[i].substringAfter(':').trim());
            ColumnWrapper tableColumn = new ColumnWrapper(columnHeaderList[i].trim(), columnFieldTypeList[i].substringBefore(':').trim(), columnFieldTypeList[i].substringAfter(':').trim());
            columnsList.add(tableColumn);
        }

        TableResponseWrapper tableToReturn = new TableResponseWrapper();
        tableToReturn.tableColumns = columnsList;
        System.debug('getTableResponse >>>' + tableToReturn);
        return tableToReturn;

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