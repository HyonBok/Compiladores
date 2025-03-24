%{
#include <stdio.h>
%}
d [0-9]
c [a-zA-Z]
%%
[\+\-]?{d}+(\.{d}+)?(E[\+\-]?{d}+)?	printf("Numero real: %s\n", yytext);
%%
int main() {
	printf("Comece a escrever:\n");
	yylex();
	return 0;
}