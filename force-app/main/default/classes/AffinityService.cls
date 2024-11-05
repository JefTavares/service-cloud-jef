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
        } catch (Exception e) {
            System.debug('error searchPolicieByDocumentName:' + e.toString());
        }

        return affinitySinResponse;
    }

}