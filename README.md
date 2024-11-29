# Projeto para estudos

# Para esse projeto foi habilitado as conta pessoais

No menu `Contas pessoais`

# Criado Novo aplicativo para testes

No menu `Gerenciador de aplicativos do Lightning Experience` chamado `TesteApps-Jef`.

Também inclui uma página `testeApp` criado no menu `Interface do usuário >> Criador de aplicativo Lightning`

E também criou a guia personalizada `testeApp` no menu `Interface do usuário >> Guias`

# Features desenvolvidas aqui.

## Aplicativos personalizados

Lá no menu `Gerenciador de aplicativos do Lightning Experience`

Gerenciador de aplicativos do Lightning Experience.

`Service Cloud Jef`

> O `contentassets >> IMG20241030WA0005.asset` no projeto é o ícone do aplicativo

## Dúvidas Gerais.

### Componentes relacionados

Lwc - modalDuvidasGerais

## Integração e API

A rota de estudo que estou utilizando é relacionado aos objetos/classes apex:

1. ComponentViewController (método getRecords)
2. AffinityService
3. IntegrationRest
4. AffinitySinDTO

### Componentes relacionados

Tipos de metadados personalizados:
ComponentView - ComponentView.Afinidades.md-meta.md, object ComponentView__mdt.object-meta.xml
API_Setting__mdt -

### Named credentials - Credenciais Nomeadas

Primeiro item a ser criado é a `Credenciais externas`
Segundo item é a `Credenciais Nomeadas`

#### Fazendo o setup - Credenciais externas.

Aqui é um passo a passo que fiz de como configurar a `Credenciais externas`

Clicar em novo.
Rótulo: SalesforceBrokerAuth
Nome: SalesforceBrokerAuth
Protocolo de autenticação: personalizado.

##### 1. entidade de segurança

Clicar em criar e definir os valores:
Nome do parâmetro: Admin
Número sequencial: 1 (Deixei o padrão 1 que veio)
Tipo de identidade: Principal nomeado (Não é possível mudar)

Em `Parâmetros de autenticação` clicar em `Adicionar`
Parâmetro 1
Nome: Username
Valor: admin

Parâmetro 2
Nome: Password
Valor: Tokio@2020

Clicar em Salvar ;)

#### 2. Cabeçalhos personalizados

Clicar em criar e definir os valores:
Nome: Authorization
Valor:
`{!'Basic ' & BASE64ENCODE(BLOB($Credential.SalesforceBrokerAuth.Username & ':' & $Credential.SalesforceBrokerAuth.Password))}`
Número sequencial: 1

A ideia é utilizar as `entidade de segurança` criadas anteriormente no cabeçalho. Por exemplo:
`$Credential.SalesforceBrokerAuth.Username` é o parâmetro 1 que criei anteriormente.

#### Fazendo o setup - Credenciais Nomeadas.

Clicar em criar e definir os valores:
Rótulo: Serviços Caixa Residencial
Nome: Servicos_Caixa_Residencial
URL: `https://servicos-aceite.caixaresidencial.com.br/ems/corporate/`
Habilitado para chamada: flegado

Autenticação:
Credenciais externas: SalesforceBrokerAuth (Criado anteriormente em `Credenciais externas`)
Certificado do cliente: em branco - não estamos utilizando.

Opções de chamada:
Gerar cabeçalho de autorização: desflegado
Permitir fórmulas no cabeçalho HTTP: flegado
Permitir fórmulas no corpo HTTP: flegado
Conexão de rede saída: Em branco

Acesso ao pacote gerenciado:
Namespace permitidos para chamada: em branco, aqui posso incluir `omnistudio,vlocity_cmt,vlocity_ins` do omnistudio, mas
no momento não vou fazer

### Cache da plataforma

O token das APIs é armazenado em `cache da plataforma`
Lá no menu `Código personalizado >>> Cache da plataforma >> Botão Nova divisão de cache da plataforma`

#### Configuração dos campos

Detail:
Rótulo: Token
Name: Token
Default Partition: desflegado
Description: Cache para armazenamento do token salesforcebroker

Alocação de cache da organização:
Organização: 1

Os demais eu deixei o padrão/default

[Cache da plataforma](https://trailhead.salesforce.com/pt-BR/content/learn/modules/platform_cache/platform_cache_use)

## Conjunto de permissões

Lista das permission sets criadas para esse projeto

### External Credential Permission

Acesso as apis do SalesforceBroker

Menus adicionados:
Acesso da entidade de segurança da credencial externa.
Adicionado a `SalesforceBrokerAuth - Admin`

## Fluxo da API e Metadados.

TODO

### ComponentView

Responsável por definir os campos a ser exibidos nas tabelas do LWC `tableReferenceView` - Componente de Tabelas.
Um component de tabelas dinâmicos.

# Git notes

No gitbash estou fazendo assim para carregar o git na firma

eval "$(ssh-agent -s)"

ssh-add /c/Temp/id_ed25519

Trocar os usuários:
De:
git config --global user.email=jeferson.tavare@caixaresidencial.com.br
git config --global user.name=ex300265
Para:
git config --global user.email=jefersontavaressilva@gmail.com
git config --global user.name "Jeferson Tavares da Silva"

git push