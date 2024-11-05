/**
 * Created by EX300265 on 05/11/2024.
 */

public with sharing class IntegrationRest {

    public class IntegrationRestException extends Exception {
    }

    //Construtor padrão da classe
    public static HttpResponse sendRequest(String serviceName, String urlParams) {
        //return sendRequest(serviceName, urlParams, null, null);
        HttpResponse responseTST = sendRequest(serviceName, urlParams, null, null);

        System.debug('IntegrationRest>sendRequest:' + serviceName + urlParams);

        return responseTST;

        //TODO linha final - return sendRequest(serviceName, urlParams, null, null);
    }

    public static HttpResponse sendRequest(String serviceName, String urlParams, Map<String, String> mapHeader, Object body) {
        HttpRequest request = generateRequest(serviceName, urlParams, mapHeader, body);
        HttpResponse response = new HttpResponse();

        response = new Http().send(request);

        System.debug(response.getBody());
        System.debug(response.getStatusCode());
        
        return response;
    }

    public static HttpRequest generateRequest(String serviceName, String urlParams, Map<String, String> mapHeader, Object body) {
        //Busca parametrização da API .getInstance já me retorna o objeto passando o developerName
        API_Setting__mdt apiSetting = API_Setting__mdt.getInstance(serviceName);
        System.debug('requestParam - apiSetting>>>' + apiSetting);
        validateRequestParams(apiSetting, serviceName);
        String urlParamsChecked = urlParams == null ? '' : urlParams; //check parâmetros da url

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + apiSetting.Named_Credential__c + apiSetting.URL_Path__c + urlParamsChecked);
        System.debug('IntegrationRest>generateRequest>>>callout:' + apiSetting.Named_Credential__c + apiSetting.URL_Path__c + urlParamsChecked);
        request.setMethod(apiSetting.Method__c);

        if (body != null) {
            System.debug(JSON.serialize(body));
            request.setBody(JSON.serialize(body));
        }

        Integer timeout = (Integer) apiSetting.Timeout__c;
        request.setTimeout(timeout);
        setHeaderValues(request, apiSetting, mapHeader);


        return request;
    }

    //setHeaderValues - com base na parametrização, monta o header da request
    private static void setHeaderValues(HttpRequest request, API_Setting__mdt apiSetting, Map<String, String> mapHeader) {

        List<API_Header_Setting__mdt> apiHeaders = [
                SELECT
                        API_Header__r.Key__c, API_Header__r.Value__c
                FROM
                        API_Header_Setting__mdt
                WHERE
                        API_Setting__c = :apiSetting.Id
        ];

        for (API_Header_Setting__mdt apiHeaderSetting : apiHeaders) {
            request.setHeader(apiHeaderSetting.API_Header__r.Key__c, apiHeaderSetting.API_Header__r.Value__c);
        }

        if (mapHeader != null && !mapHeader.isEmpty()) {
            for (String key : mapHeader.keySet()) {
                request.setHeader(key, mapHeader.get(key));
            }
        }
    }

    private static void validateRequestParams(API_Setting__mdt apiSetting, String serviceName) {
        if (String.isBlank(serviceName)) {
            throw new IntegrationRestException('O parâmetro de serviço não pode ser vazio ou nulo');
        }
        if (apiSetting == null) {
            throw new IntegrationRestException('O serviço ' + serviceName + ' não existe na configuração das APIs');
        }
        if (!apiSetting.IsActive__c) {
            throw new IntegrationRestException('A integração ' + apiSetting.Label + ' está com o status desativado na configuração das APIs');
        }
    }

}