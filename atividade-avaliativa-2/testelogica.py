def validacaoDeResposta(reposta):
    if reposta != 'V' and reposta != 'E' and reposta != 'D':
        print('Resposta inválida')
        while(True):
            novaPergunta = input(f'\nResposta inválida, digite novamente: ')

            if novaPergunta != 'V' and novaPergunta != 'E' and novaPergunta != 'D':
                continue
            else:
                return novaPergunta
    else:
        return reposta

totalPontos = 0

print('### Ranqueada Call os Nassau ###')
print('\nDigite abaixo: \nV - Vitório \nE - Empate \nD - Derrota')

for num in range(1,11,1):
    pergunta = input(f'\nDigite o resultado da {num}° partida: ')

    resultadoValidacao = validacaoDeResposta(pergunta)

    if resultadoValidacao == 'V':
        totalPontos += 10
        print('\nVocê ganhou 10 pontos')

    if resultadoValidacao == 'E':
        totalPontos += 5
        print('\nVocê ganhou 5 pontos')

    if resultadoValidacao == 'D':
        totalPontos -= 2
        print('\nVocê perdeu 2 pontos')

print(f'\nVocê tem {totalPontos} de pontos')

if totalPontos >= 60:
    print(f'\nVocê subiu de patente!')
elif totalPontos >= 21:
    print(f'\nVocê permanecerá na patente atual')
else:
    print(f'\nVocê caiu de patente')
