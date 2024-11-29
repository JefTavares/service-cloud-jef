/**
 * Created by EX300265 on 05/11/2024.
 */

public class TokenManager {

    private class TokenInfoResponse {
        public String access_token;
        public String token_type;
        public String expires_in;
    }

    public class TokenManagerException extends Exception {

    }

    //Exemplo de nome de cache: 'local.nomeDaParticao.chaveDoCache' - Ex: 'local.Token.salesforceBroker'
    public static String getToken(String cacheName, String serviceName) {
        System.debug('getToken>' + cacheName + ' ' + serviceName);
        String token;
        try {
            System.debug('Cache.Org.get(cacheName)>' + Cache.Org.get(cacheName));

            if (Cache.Org.get(cacheName) != null) {
                //Caso token no cache seja null ele busca um novo token no
                token = (String) Cache.Org.get(cacheName);
                return token;
            }

            token = setToken(cacheName, serviceName);
        } catch (TokenManagerException e) {
            System.debug('Erro no token:' + e.getMessage());
            throw new TokenManagerException(e.getMessage());
        }

        return token;
    }

    //Define o token da integração Salesforce Broker
    private static String setToken(String cacheName, String serviceName) {
        System.debug('setToken>' + cacheName + ' ' + serviceName);

        String token;
        String urlParams = '?grant_type=client_credentials';
        try {
            HttpResponse response = IntegrationRest.sendRequest(serviceName, urlParams);

            if (response.getStatusCode() != 200) {
                System.debug('teste >>> ' + response.getBody());
                throw new TokenManagerException('Falha ao capturar token - status code: ' + response.getStatusCode());
            }
            TokenInfoResponse tokenInfo = (TokenInfoResponse) JSON.deserialize(response.getBody(), TokenInfoResponse.class);

            token = tokenInfo.token_type + ' ' + tokenInfo.access_token;
            System.Integer.valueOf(tokenInfo.expires_in);
            Cache.Org.put(cacheName, token, Integer.valueOf(tokenInfo.expires_in), Cache.Visibility.ALL, true);
        } catch (TokenManagerException e) {
            System.debug('setToken error:' + e.getMessage());
            throw new TokenManagerException(e.getMessage());
        }

        return token;
    }
}