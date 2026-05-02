# Regras Connect4
> ### As regras foram extraídas do artigo:
> A Knowledge-based Approach of Connect-Four
>> The Game is Solved: White Wins
>>> Victor Allis

---

## Regras principais
### Regra 1: Zugzwang

Sempre tentar controlar a coluna a partir de uma linha par (ou quando a quantidade de espaços vazios em uma coluna for ímpar), para forçar o inimigo a sempre precisar escolher uma coluna nova.  
"This enables us to define the concept of Control of Zugzwang: A is in control of the Zugzwang if he is able to guide the way odd and even squares are divided among both players."

#### Quem controla o Zugzwang?
- Jogador A: 
    - Se possuir ameaça em linha ímpar e espaços vazios disponíveis nas colunas for par;
    - Priorizar possíveis vitórias (ameaças) em linhas ímpar (para evitar o Zugzwang)

- Jogador B:
    - Se possuir ameaça em linha par e espaços vazios disponíveis nas colunas for ímpar
    - Priorizar possíveis vitórias (ameaças) em colunas par (para aplicar o Zugzwang)

### Regra 2: Claimeven
> Preferir jogadas em linhas pares SEMPRE que possível

"For now it suffices to note that if B controls the Zugzwang, he can claim an even square, if the odd square below the even square is still empty. In that case he will take the even square as soon as A has played the odd square below."  
"A Claimeven is therefore concerned with two squares, an odd and an even square, both empty, lying directly above each other. All groups which contain the even square are solved by the Claimeven"

>Claimeven formally:
>
>Required:  
>Two squares, directly above each other. Both squares should be empty. The upper square must be even.
>
>Solutions:  
>All groups which contain the upper square.

### Regra 3: Baseinverse
"If two squares are directly playable, and both squares are part of the same group, player A can always prevent player B from completing the group, by playing one square as soon as player B plays the other."

>Baseinverse formally:
>
>Required:  
>Two directly playable squares.
> 
>Solutions:  
>All groups which contain both squares.

---
## Outras regras
 
### Regra 4: Vertical
>Vertical formally:
>
>Required:  
>Two squares directly above each other. Both squares should be empty. The upper square must be odd.
>
>Solutions:  
>All groups which contain both squares.

### Regra 5: Aftereven
>Aftereven formally:
>
>Required:  
>A group which can be completed by the controller of the Zugzwang, using only the even squares of a set of Claimevens. This group is called the Aftereven group. The columns in which the empty squares lie are called the Aftereven columns.
>
>Solutions:  
>All groups which have at least one square in all Aftereven columns, above the empty square of the Aftereven group in that column. All groups which are solved by the Claimevens, which are part of the Aftereven.

### Regra 6: Lowinverse
>Lowinverse formally:
>
>Required:  
>Two different columns, called the Lowinverse columns. In each Lowinverse column two squares, lying directly above each other.  
>All four squares must be empty. In both columns the upper of the two squares is odd.
>
>Solutions:  
>All groups which contain both upper squares. All groups which are solved by the Verticals, which are part of the Lowinverse."

### Regra 7: Highinverse
>Highinverse formally:
>
>Required:  
>Two different columns, called the Highinverse columns. In each Highinverse column three squares, lying directly above each other.  
>All six squares are empty.  
>In both columns the upper square is even.  
>
>Solutions:  
>All groups which contain the two upper squares.  
>All groups which contain the two middle squares.  
>All (vertical) groups which contain the two highest squares of one of the Highinverse columns.  
>
>If the lower square of the first column is directly playable:  
>All groups which contain both the lower square of the first column and the upper square of the second column.
>
>If the lower square of the second column is directly playable:  
>All groups which contain both the lower square of the second column and the upper square of the first column.

### Regra 8: Baseclaim
>Baseclaim formally:
>
>Required:  
>Three directly playable squares and the square above the second playable square.
>The non-playable square must be even.
>
>Solutions:  
>All groups which contain the first playable square and the square above the second playable square.  
>All groups which contain the second and third playable square.

### Regra 9: Before
>Before formally:
>
>Required:  
>A group without men of the opponent, which is called the Before group.  
>All empty squares of the Before group should not lie in the upper row of the board.
>
>Solutions:  
>All groups which contain all squares which are successors of empty squares in the Before group.  
>All groups which are solved by the Verticals which are part of the Before.  
>All groups which are solved by the Claimevens which are part of the Before.

### Regra 10: Specialbefore
>Specialbefore formally:
>
>Required:  
>A group without men of the opponent, which is called the Specialbefore group.
>A directly playable square in another column.  
>All empty squares of the Specialbefore group should not lie in the upper row of the board.  
>One empty square of the Before group must be playable.  
>
>Solutions:  
>All groups which contain all successors of empty squares of the Specialbefore group and the extra playable square.  
>All groups which contain the two playable squares.  
>All groups which are solved by one of the Claimevens.  
>All groups which are solved by one of the Verticals.

