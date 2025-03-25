%{
#include <stdio.h>
%}

/* Definições */

d [0-9]
l [a-z]
L [A-z]

/* 
U: 0-9 
D: 10-90 
C: 100-900
M: 1000-3000
*/
U I(V|X)|V|(V?I{0,3})
D X(L|C)|L|(L?X{0,3})
C C(D|M)|D|(D?C{0,3})
M M{0,3}

%%

\({d}{2}\){d}{5}-{d}{4}         { printf("Numero De telefone: %s\n", yytext); }

{L}{3}{d}{L}{d}{2}              { printf("Placa De carro: %s\n", yytext); }

{M}?{C}?{D}?{U}?                       { printf("Numero romano: %s\n", yytext); }
