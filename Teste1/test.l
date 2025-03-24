%{
#include <stdio.h>
%}
d [0-9]
c [a-zA-Z]
%%
\({d}{2}\){d}{5}-{d}{4}		printf("Numero telefone: %s\n", yytext);

[\+\-]?{d}+(\.{d}+)?(E[\+\-]?{d}+)?	printf("Numero encontrado: %s\n", yytext);
%%
int main() {
	printf("Comece a escrever:\n");
	yylex();
	return 0;
}
