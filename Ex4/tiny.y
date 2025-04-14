%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

float vars[26];
%}

%union {
    int ival;
    float fval;
    char cval;
}

%token <fval> NUM
%token <cval> VAR
%token IF ELSE
%token SUM SUB MUL DIV ATB
%token OPARENT CPARENT OBRACKET CBRACKET 
%token GREATER LESS GEQUAL LEQUAL EQUAL DIF OR AND NOT TRUE FALSE

%type <ival> logic comand_if
%type <fval> exp factor termo comand_atb 

%left SUM SUB MUL DIV
%left GREATER LESS GEQUAL LEQUAL EQUAL DIF OR AND NOT TRUE FALSE

%%

/* Programa */

calc:   
 | calc comand_atb;
 | calc VAR { printf("%c = %f\n", $2, vars[$2-'a']); }    // So pra saber o valor da variavel        
 | calc comand_if { printf("%d\n", $2); }                 // Retorna valor atribuido no if
 ;

comand_if: 
   IF OPARENT logic CPARENT OBRACKET comand_atb CBRACKET { if($3 != 0) { $$ = $6; } }
 | IF OPARENT logic CPARENT OBRACKET comand_atb CBRACKET ELSE OBRACKET comand_atb CBRACKET { if($3) { $$ = $6; } else { $$ = $10; } }
 ;

comand_atb:
  VAR ATB exp { vars[$1-'a'] = $3; $$ = $3; }
  ;

/* Comparacao */

logic: 
   exp GREATER exp  { if($1 > $3) { $$ = 1; } else { $$ = 0; } }
 | exp GEQUAL exp { if($1 >= $3) { $$ = 1; } else { $$ = 0; } }
 | exp LESS exp { if($1 < $3) { $$ = 1; } else { $$ = 0; } }
 | exp LEQUAL exp { if($1 <= $3) { $$ = 1; } else { $$ = 0; } }
 | exp EQUAL exp { if($1 == $3) { $$ = 1; } else { $$ = 0; } }
 | exp DIF exp { if($1 != $3) { $$ = 1; } else { $$ = 0; } }
 | logic OR logic { if($1 || $3) { $$ = 1; } else { $$ = 0; } }
 | logic AND logic { if($1 && $3) { $$ = 1; } else { $$ = 0; } }
 | NOT OPARENT logic CPARENT { if($3) { $$ = 0; } else { $$ = 1; } }
 | TRUE { $$ = 1; }
 | FALSE { $$ = 0; }
 | exp { if($1) { $$ = 1; } else { $$ = 0; } }
 ;

/* Aritmetica */

exp:
   factor
 | exp SUM exp { $$ = $1 + $3; }
 | exp SUB exp { $$ = $1 - $3; }
 ;

factor:
   termo
 | factor MUL factor { $$ = $1 * $3; }
 | factor DIV factor { $$ = $1 / $3; }
 ;

termo: 
   NUM
 | VAR { $$ = vars[$1-'a']; } 
 | OPARENT exp CPARENT { $$ = $2; }
 ; 

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
