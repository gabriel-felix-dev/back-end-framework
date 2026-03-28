## Exemplo prático - 

# nome = input("Qual o seu nome? ")
# idade = int(input("Qual a sua idade? "))

# print(f"Olá, {nome}!")

# if idade >= 18:
#     print("Você é maior de idade.")
# else:
#     print("Você é menor de idade.")

## Desafio 1 - 

# numero1 = int(input("Digite o primeiro número: "))
# numero2 = int(input("Digite o segundo número: "))

# soma = numero1 + numero2

# print(f"A soma dos números é {soma}.")

## Desafio 2 -

# nomeAluno = input("Digite o nome do aluno: ")
# nota1 = float(input("Digite a primeira nota: "))
# nota2 = float(input("Digite a segunda nota: "))

# media = (nota1 + nota2) / 2

# print(f"A média do aluno é {media}.")

# Exercicios 

## Questão 01

# numero = int(input("Digite um número: "))

# if numero > 0:
#     print(f"O número {numero} é positivo.")
# elif numero == 0:
#     print(f"O número é zero.")
# else: 
#     print(f"O número {numero} é negativo.")

## Questão 02

# lado1 = int(input("Digite o valor do primeiro lado: "))
# lado2 = int(input("Digite o valor do segunfo lado: "))
# lado3 = int(input("Digite o valor do terceiro lado: "))

# if(lado1 == lado2 and lado2 == lado3 and lado3 == lado1):
#     print("O triângulo é um Equilátero")
# elif(lado1 == lado2 or lado2 == lado3 or lado3 == lado1):
#     print("O trinângulo é Isósceles")
# else:
#     print("O triângulo é Escaleno")

## Questão 03

# altura = float(input("Digite a alutra da pessoa: "))
# peso = float(input("Digite o peso da pessoa: "))

# imc = peso / (altura * altura)

# if imc < 18.5:
#     print(f"Peso: {peso} | Altura: {altura} | IMC: {imc:.2f} - Abaixo do peso")
# elif imc <= 24.9:
#     print(f"Peso: {peso} | Altura: {altura} | IMC: {imc:.2f} - Peso ideal")
# elif imc <= 29.9:
#     print(f"Peso: {peso} | Altura: {altura} | IMC: {imc:.2f} - Sobrepeso")
# elif imc <= 34.9:
#     print(f"Peso: {peso} | Altura: {altura} | IMC: {imc:.2f} - Obesidade Grau I")
# elif imc <= 39.9:
#     print(f"Peso: {peso} | Altura: {altura} | IMC: {imc:.2f} - Obesidade Grau II")
# else: 
#     print(f"Peso: {peso} | Altura: {altura} | IMC: {imc:.2f} - Obesidade Grau III")

## Questão 04

velocidadeMotorista = int(input("Digite a velocidade do motorista: "))

velocidadeMaxima = int(50)

if velocidadeMaxima > velocidadeMotorista or velocidadeMaxima == velocidadeMotorista:
    print("Motorista dentro da velocidade permitida")
else:
    print("Limite de velocidade ultrapassado pelo motorista")
