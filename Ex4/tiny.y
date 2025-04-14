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

%right SUM SUB MUL DIV

%type <ival> logic 
%type <fval> exp comand_atb comand_if

%%

/* Programa */

calc:   
 | calc comand_atb;
 | calc VAR { printf("%c = %f\n", $2, vars[$2-'a']); }    // So pra saber o valor da variavel        
 | calc comand_if { printf("%f\n", $2); }                 // Retorna valor atribuido no if
 ;

comand_if: 
   IF logic OBRACKET comand_atb CBRACKET { if($2 != 0) { $$ = $4; } }
 | IF logic OBRACKET comand_atb CBRACKET ELSE OBRACKET comand_atb CBRACKET { if($2) { $$ = $4; } else { $$ = $8; } }
 ;

comand_atb:
  VAR ATB exp { vars[$1-'a'] = $3; $$ = $3; }
  ;

/* Comparacao */

logic: 
   OPARENT exp GREATER exp CPARENT  { if($2 > $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT exp GEQUAL exp CPARENT { if($2 >= $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT exp LESS exp CPARENT { if($2 < $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT exp LEQUAL exp CPARENT { if($2 <= $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT exp EQUAL exp CPARENT { if($2 == $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT exp DIF exp CPARENT { if($2 != $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT logic OR logic CPARENT { if($2 || $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT logic AND logic CPARENT { if($2 && $4) { $$ = 1; } else { $$ = 0; } }
 | OPARENT NOT logic CPARENT { if($3) { $$ = 0; } else { $$ = 1; } }
 | OPARENT TRUE CPARENT { $$ = 1; }
 | OPARENT FALSE CPARENT { $$ = 0; }
 | OPARENT exp CPARENT { if($2) { $$ = 1; } else { $$ = 0 } }
 ;

/* Aritmetica */

exp:
   NUM
 | VAR                  { $$ = vars[$1 - 'a']; }
 | exp SUM exp          { $$ = $1 + $3; }
 | exp SUB exp          { $$ = $1 - $3; }
 | exp MUL exp          { $$ = $1 * $3; }
 | exp DIV exp          { $$ = $1 / $3; }
 | OPARENT exp CPARENT  { $$ = $2; }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
