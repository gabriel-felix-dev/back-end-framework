# Sistema de Academia

## Entidades 

### O sistema terá 4 entidades:

1. Plano
2. Aluno
3. Professor
4. Treino

## 1. Plano

O **Plano** é a entidade mais simples do banco. Ela possui apenas o campo de Id (**Primary Key**) e Nome.

 A modelagem dela abrange apenas 4 tipos de planos: 

| Id   | Nome             | 
| :--: | :--------------: | 
|1     | Plano Mensal     | 
|2     | Plano Trimestral | 
|3     | Plano Semestral  | 
|4     | Plano Anual      |

> Esses valores já estão cadastrados na base de dados

## 2. Aluno 

A entidade **Aluno** possuí os seguintes campos: 

- Id (**Primary Key**)
- IdPlano (**Foreign Key** da entidade **Plano**)
- Nome
- Cpf 
- Email 
- Telefone 
- Senha 

> Um Aluno pode ter um somente um Plano. Um Plano ter mais de um Aluno.
>
> Uma vez com acesso ao sistema o Aluno poderá:
>> 1. Ver a sua lista de Treinos;
>> 2. Mudar de Plano
>> 3. Alterar suas informações
>> 4. Excluir sua conta

## 3. Professor

A entidade **Professor** possuí os seguintes campos: 

- Id (**Primary Key**)
- Nome
- Cpf 
- Email 
- Telefone 
- Senha

> Uma vez com acesso ao sistema o Professor poderá: 
>> 1. Ter acesso a lista de Alunos;
>> 2. Cadastrar um Treino para um Aluno;
>> 3. Ver a lista de Treinos que ele é responsável;
>> 4. Alterar o Treino de um Aluno
>> 5. Excluir o Treino de um Aluno;
>> 6. Alterar suas informações
>> 7. Excluir sua conta

## 4. Treino

A entidade central do sistema será o **Treino**. Ela será a relação entre o Aluno e o Professor. A entidade Treino possuí os seguintes campos:

- Id (**Primary Key**)
- IdAluno (**Foreign Key** da entidade **Aluno**)
- IdProfessor (**Foreign Key** da entidade **Professor**)
- Titulo 
- Descricao 
- DataCriacao (Preenchida automaticamente no momento da criação da entidade)

> Um Professor pode ter mais de um Treino.
>
> Um Aluno pode ter mais de um Treino.
>
> Um Treino pode ter mais de um Aluno e mais de um Professor. 

## Fucionalidades do sistema: 

### Cadastro:

1. A tela inicial do sistema será de Login que com uma opção de cadastro para Professor ou Aluno;
    1. Somente cadastro do Aluno terá as 4 opções de plano;
2. O cadastro do Treino será feito somente pelo Professor em seu acesso;
    1. O Treino terá a Primary Key do Aluno que o Professor escolher e a sua prórpria Primary Key;
