# Sessão de Usuário

Estado de autenticação e interação de usuário
TODO: REVISAR ESSA PARTE

## Importância:

- Manter o usuários autenticados
- Controla permissão de acesso - Definiar Adm de usuário comum
- Armazenar dados temporários
- Garantir segurança durante a navegação
- Melhorar experiência

Martin Fowler - Gerenciamento de estado é essencial para sistemas, pois permite rastreabilidade, seg e consistência nas operações realizadas pelo usuário.

## Como as sessões funcionam:

1. Usuário realiza login
2. Backend valida credenciais
3. Servidor cria uma sessão
4. Um identificador é enviado ao cliente - Identificador = Token
5. O cliente envia esse identificador nas próximas requisições

OBS: Os Tokens ficam do lado do usuário e não no servidor.

Adrew S Tanenbaum - Sistemas distribuidos dependem fortemente de mecanismos de identificação e presistência tempóraria para manter comunicação confiável entre cliente e servidor.

## Sessão e segurança

As sessões contribuem diretamente para a segurança da aplicação: 

- Evitam envio constante de senha - protege contra "sniffer" (Malwere)
- Permitem expiração automática
- Reduzem risco de acesso indevido
- Facilitam  logout e invalidação de acesso - Desativa o Token de login

Bruce Schneier - TODO: REVISAR ESSA PARTE

## Formas de sessão - Tradicional VS JWL

- Tradicional
    - Dados armazenados no servidor
    - Mais controle centralizado
    - Fácil invalidação

- JWT (JSON Web Token)
    - Dados armazenados no token
    - Melhor escalabilidade
    - Muito utilizado em Api's

## Bibliotecas:

- Flask-Mail: Envia um código para o e-mail do usuário;

- Random: Biblioteca python que gera números pseudoaleatórios;

## Flask-Mail

Integra os serviços de e-mail em aplicações python

Instalação: `pip install Flask-Mail`

### Funcionamento:

1. O back configura um servidor SMTP
2. O Flask-Mail estabelece uma conexão com o server
3. Uma mensagem é criada
4. O server autentica o envio
5. O e-mail é enviado ao destinatário

### Configuração SMTP

porta padrão de envio SMT - 587
