/**
 * @description       :
 * @author            : Jeferson Tavares
 * @group             :
 * @last modified on  : 12-13-2024
 * @last modified by  : Jeferson Tavares
 **/

public with sharing class AccountTriggerHelper {
    //construtor vazio para os helpers
    public AccountTriggerHelper() {
    }

    // verifica se tem contas duplicadas. O campo cpf é a chave única dos clientes.
    public void checkDuplicatedAccount(List<Account> newAccount) {
        System.debug('checkDuplicatedAccount >>>' + newAccount);
        Set<String> cpfs = new Set<String>();//Lista de valores unicos
        Map<String, Map<String, Set<String>>> cpfXrecordtype = new Map<String, Map<String, Set<String>>>();

        for (Account conta : newAccount) {
            System.debug('conta.cpf_cnpj__c >>>' + conta.CPF_CNPJ__c);
            cpfs.add(conta.CPF_CNPJ__c);
            if (cpfXrecordtype.containsKey(conta.CPF_CNPJ__c)) {
                if (cpfXrecordtype.get(conta.CPF_CNPJ__c).containsKey(conta.RecordTypeId)) {
                    cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).add(conta.Id == null ? String.valueOf(cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).size()) : conta.Id);
                } else {
                    cpfXrecordtype.get(conta.CPF_CNPJ__c).put(conta.RecordTypeId, new Set<String>{
                            conta.Id == null ? '0' : conta.Id
                    });
                }
            } else {
                /* cria um map novo para cada cpf que veio na trigger.
                 {cpf => {recordtype => {id da conta}}}
                Exemplo:
                cpfXrecordtype.put('01185631143', new Map<String, Set<String>>{
                        '012HZ000001WO8IYAW' => new Set<String>{
                                '001HZ00000KaHk5YAF'
                        }
                });
                */
                cpfXrecordtype.put(conta.CPF_CNPJ__c, new Map<String, Set<String>>{
                        conta.RecordTypeId => new Set<String>{
                                conta.Id == null ? '0' : conta.Id
                        }
                });
            }
        }
        System.debug('cpfXrecordtype >>>' + cpfXrecordtype);
        //Popula o cpfXrecordtype com as contas que existem no Salesforce com o mesmo cpf
        for (Account conta : [SELECT Id, RecordTypeId, CPF_CNPJ__c FROM Account WHERE CPF_CNPJ__c IN :cpfs]) {
            if (cpfXrecordtype.containsKey(conta.CPF_CNPJ__c)) {
                if (cpfXrecordtype.get(conta.CPF_CNPJ__c).containsKey(conta.RecordTypeId)) {
                    cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).add(conta.Id);
                } else {
                    cpfXrecordtype.get(conta.CPF_CNPJ__c).put(conta.RecordTypeId, new Set<String>{
                            conta.Id
                    });
                }
            } else {
                cpfXrecordtype.put(conta.CPF_CNPJ__c, new Map<String, Set<String>>{
                        conta.RecordTypeId => new Set<String>{
                                conta.Id
                        }
                });
            }
        }
        System.debug('cpfXrecordtype2 >>>' + cpfXrecordtype);

        //Valida se existe um cpf para o mesmo tipo de conta RecordTypeId
        for (Account conta : newAccount) {
            if (cpfXrecordtype.containsKey(conta.CPF_CNPJ__c)) {
                if (cpfXrecordtype.get(conta.CPF_CNPJ__c).containsKey(conta.RecordTypeId)) {
                    if (conta.Id == null) {
                        if (cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).size() > 1) {
                            conta.addError('Já existe um CPF/CNPJ deste tipo de conta');
                        }
                    } else if (cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).size() > 1
                            || (!(cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).contains(conta.Id)) &&
                            cpfXrecordtype.get(conta.CPF_CNPJ__c).get(conta.RecordTypeId).size() == 1)) {
                        conta.addError('Já existe um CPF/CNPJ deste tipo de conta');
                    }
                }
            }
        }
    }

}