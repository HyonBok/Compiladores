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
%token SE SENAO ENTAO
%token LPARENT RPARENT
%token EOL

%type <fval> exp
%type <fval> fator

%%

/* Programa */

calc:                  
 | calc exp EOL { printf("= %f\n", $2); }
 | calc atrib EOL { }
 | calc VAR EOL { printf("%c = %f\n", $2, vars[$2-'a']); }
 ;

/* Comparacao */

/* Aritmetica */

atrib:
 VAR ATB exp { vars[$1-'a'] = $3; }
 ;

exp: fator 
 | exp ADD exp { $$ = $1 + $3; }
 | exp SUB exp { $$ = $1 - $3; }
 ;

fator: NUMBER
 | VAR { $$ = vars[$1-'a']; }
 | fator MUL fator { $$ = $1 * $3; }
 | fator DIV fator { $$ = $1 / $3; }
 ;

// par: LPARENT fator RPARENT

/*
    <comando> -> <comando_if> 
    <comando> -> <atrib> 
    <comand_if> -> if (expr_logica) then { <atrib> }
    <comand_if> -> if (expr_logica) then { <atrib> } else { <atrib> }
    <expr_logica> -> op1 <op_cmp> op2 | (<exp_logica> OR <exp_logica>) | (<exp_logica> AND <exp_logica>) | (NOT <exp_logica>)
    <op_cmp> -> < | > | <= |>= | !=
*/

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    printf("Digite uma expressão:\n");
    yyparse();
    return 0;
}
