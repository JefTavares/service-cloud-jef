/**
 * Created by EX300265 on 05/11/2024.
 */

public class AffinityService {

    public static AffinitySinDTO.AffinitySinResponse searchPolicieByDocumentName(String cpfCnpj, String nomeSegurado) {

        HttpResponse response;
        AffinitySinDTO.AffinitySinResponse affinitySinResponse;
        try {
            Map<String, String> mapHeader = new Map<String, String>();
            mapHeader.put('Authorization', TokenManager.getToken('local.Token.salesforceBroker', 'Get_Token'));
            System.debug('AffinityService>token>' + mapHeader);

            AffinitySinDTO.AffinitySinRequest affinitySinRequest = new AffinitySinDTO.AffinitySinRequest();
            affinitySinRequest.documentoCPFCNPJ = cpfCnpj;
            affinitySinRequest.nomeSegurado = nomeSegurado;

            //Chama a api
            response = IntegrationRest.sendRequest('Affinity_Sin', mapHeader, affinitySinRequest);

            if (response.getStatusCode() == 200) {
                affinitySinResponse = new AffinitySinDTO.AffinitySinResponse();
                affinitySinResponse = AffinitySinDTO.parse(response.getBody());
                System.debug('cod 200>' + affinitySinResponse);
            }
        } catch (Exception e) {
            System.debug('error searchPolicieByDocumentName:' + e.toString());
        }

        return affinitySinResponse;
    }
}