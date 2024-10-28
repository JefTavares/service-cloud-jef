/**
 * @description : Controller do componente datatable, responsável por chamar as apis e mais
 * @author : Jeferson Tavares - EX300265
 * Created by EX300265 on 28/10/2024.
 */

public with sharing class ComponentViewController {

    // Retorna os dados de api
    public static Map<String, String> getRecords(String dataString) {
        DataWrapper dataWrapper = (DataWrapper) JSON.deserialize(dataString, DataWrapper.class); //todo Incluir na classe
        Map<String, String> mapToReturn = getDataFromAPI(dataWrapper);

        return mapToReturn;
    }

    public static Map<String, String> getDataFromAPI(DataWrapper dataWrapper) {
        Map<String, String> mapToReturn = new Map<String, String>();
        System.debug('dataWrapper >>>' + dataWrapper);
        System.debug(dataWrapper.metadataName);

        return mapToReturn;
    }

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
}