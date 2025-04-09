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

%token <fval> NUM
%token <cval> VAR
%token SOMA SUB MUL DIV ATB
%token SE SENAO
%token APARENT FPARENT ACHAVE FCHAVE ACOM FCOM
%token MAIOR MENOR MAIORIGUAL MENORIGUAL IGUAL DIF
%token OU E NAO

%type <fval> exp
%type <fval> fator
%type <fval> termo

%%

/* Programa */

calc:                  
 | calc exp { printf("= %f\n", $2); }
 | calc atrib { }
 | calc VAR { printf("%c = %f\n", $2, vars[$2-'a']); }
 ;

comando: 
 | comando_atrib { }
 | comando_se { }
 ;

comando_atrib:
 VAR ATB par { vars[$1-'a'] = $3; }
 ;

comando_se: 
 SE APARENT logica FPARENT ACHAVE comando FCHAVE
 | SE APARENT logica FPARENT ACHAVE comando FCHAVE SENAO ACHAVE comando FCHAVE
 ;

/* Comparacao */

logica: 
 termo MAIOR termo { if($1 > $3) { $$ = 1; } else { $$ = 0; } }
 | termo MAIORIGUAL termo { if($1 >= $3) { $$ = 1; } else { $$ = 0; } }
 | termo MENOR termo { if($1 < $3) { $$ = 1; } else { $$ = 0; } }
 | termo MENORIGUAL termo { if($1 <= $3) { $$ = 1; } else { $$ = 0; } }
 | termo IGUAL termo { if($1 == $3) { $$ = 1; } else { $$ = 0; } }
 | termo DIF termo { if($1 != $3) { $$ = 1; } else { $$ = 0; } }
 | logica OU logica { if($1 || $3) { $$ = 1; } else { $$ = 0; }}
 | logica AND logica { if($1 && $3) { $$ = 1; } else { $$ = 0; }}
 | NAO logica { if($2) { $$ = 0; } else { $$ = 1; }}
 ;

/* Aritmetica */

exp: fator 
 | exp SOMA exp { $$ = $1 + $3; }
 | exp SUB exp { $$ = $1 - $3; }
 ;

fator: termo
 | fator MUL fator { $$ = $1 * $3; }
 | fator DIV fator { $$ = $1 / $3; }
 ;

termo: NUM
 | VAR { $$ = vars[$1-'a']; } 
 | APARENT exp FPARENT { $$ = $2; }
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
