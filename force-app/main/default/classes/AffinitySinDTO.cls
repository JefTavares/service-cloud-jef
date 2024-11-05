/**
 * @description       : Classe DTO para a API searchApolicesByDocumentName
 * @author            : Jeferson Tavares
 * @last_modified_on  : 11-05-2024
 * @last modified by  : Jeferson Tavares
**/
public class AffinitySinDTO {

    public class AffinitySinResponse {
        @AuraEnabled public PolicieAffinity return_x;
    }

    public class AffinitySinRequest {
        @AuraEnabled public String documentoCPFCNPJ;
        @AuraEnabled public String nomeSegurado;
    }

    public class PolicieAffinity {
        @AuraEnabled public List<Policie> apolice;
        @AuraEnabled public Status status;
    }

    public class Policie {
        @AuraEnabled public Key chave;
        @AuraEnabled public Data dados;
        @AuraEnabled public Status status;
    }

    public class Key {
        @AuraEnabled public String numeroSegurado;
        @AuraEnabled public String idChaveAcselx;
        @AuraEnabled public String codigoCompanhiaSeguradoraEmissao;
        @AuraEnabled public String codigoRamoProduto;
        @AuraEnabled public String codigoApolice;
        @AuraEnabled public String codigoEndosso;
        @AuraEnabled public String codigoTipoEndosso;
        @AuraEnabled public String codigoItemApolice;
    }


    public class Data {
        @AuraEnabled public String capital;
        @AuraEnabled public String cep;
        @AuraEnabled public String certificado;
        @AuraEnabled public String codCobertura;
        @AuraEnabled public String codCorretor;
        @AuraEnabled public String codSucursal;
        @AuraEnabled public String complemento;
        @AuraEnabled public String ddd;
        @AuraEnabled public String descricaoBemSegurado;
        @AuraEnabled public String descricaoPlano;
        @AuraEnabled public String dtCancelamento;
        @AuraEnabled public String dtnascimento;
        @AuraEnabled public String email;
        @AuraEnabled public String endosso;
        @AuraEnabled public String logradouro;
        @AuraEnabled public String matriculaSegurado;
        @AuraEnabled public String nome;
        @AuraEnabled public String nomeCobertura;
        @AuraEnabled public String nomeCorretor;
        @AuraEnabled public String nomeEstipulante;
        @AuraEnabled public String nomeSucursal;
        @AuraEnabled public String numContrato;
        @AuraEnabled public String numSegurado;
        @AuraEnabled public String numero;
        @AuraEnabled public String numeroApolice;
        @AuraEnabled public String premio;
        @AuraEnabled public String status;
        @AuraEnabled public String telefone;
        @AuraEnabled public String tipoCML;
        @AuraEnabled public String tipoIdentificacao;
        @AuraEnabled public String tipoPessoa;
        @AuraEnabled public String tipoCobertura;
        @AuraEnabled public String uf;
        @AuraEnabled public String valorMaximoFranquia;
        @AuraEnabled public String valorMinimoFranquia;
        @AuraEnabled public String valorPercentualFranquia;
        @AuraEnabled public String vigFinal;
        @AuraEnabled public String vigInicial;
    }

    public class Status {
        @AuraEnabled public String codigoRetornoConsulta;
        @AuraEnabled public String descricaoRetornoConsulta;
    }

    public static AffinitySinDTO.AffinitySinResponse parse(String jsonResponse) {
        AffinitySinDTO.AffinitySinResponse affiniitySinResponse = (AffinitySinDTO.AffinitySinResponse) JSON.deserialize(jsonResponse.replace('return', 'return_x'), AffinitySinDTO.AffinitySinResponse.class);

        Map<String, String> apiValuesXPicklistValues = new Map<String, String>{
                'CAIXA SEGURO HABITACIONAL MAIS' => 'Habitacional Mais',
                'CAIXA SEGURO HABITACIONAL ESPECIAL' => 'Habitacional Especial',
                'CAIXA SEGURO HABITACIONAL' => 'Habitacional'
        };
        for (Policie policy : affiniitySinResponse.return_x.apolice) {
            policy.dados.descricaoPlano = UtilityClass.replaceValues(policy.dados.descricaoPlano, apiValuesXPicklistValues);
        }


        return affiniitySinResponse;
    }
}