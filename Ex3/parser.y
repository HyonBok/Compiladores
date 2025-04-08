%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

float vars[26];
%}

%union {
    float fval;
    char cval;
}

%token <fval> NUMBER
%token <cval> VAR
%token ADD SUB MUL DIV ATB
%token EOL

%type <fval> exp

%%

calc:                  
 | calc exp EOL { printf("= %f\n", $2); }
 | calc EOL { printf("Digite algo!\n"); }
 | calc atrib EOL {}
 ;

exp: NUMBER 
 | VAR { $$ = vars[$1-'a']; }
 | exp exp ADD { $$ = $2 + $1; }
 | exp exp SUB { $$ = $2 - $1; }
 | exp exp MUL { $$ = $2 * $1; }
 | exp exp DIV { $$ = $2 / $1; }
 ;

atrib:
 VAR ATB exp { vars[$1-'a'] = $3; printf("%c = %f\n", $1, $3); }
 ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    printf("Digite uma expressão:\n");
    yyparse();
    return 0;
}
