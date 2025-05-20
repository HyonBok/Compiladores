%{
  #include <stdio.h> 
  #include <math.h>  
  #include "symbol.h"  
  extern FILE *yyin; 
  int yylex (void);
  void yyerror (char const *);
%}

%union {
    int ival;
    float fval;
    char cval;
	char* string;
}

%token <fval> NUM
%token SUM SUB MULT DIV ATB
%token IF ELSE 
%token EQUAL LESS GREATER LEQUAL DIF GEQUAL AND OR NOT 
%token OB CB OP CP
%token BTRUE BFALSE
%token INT FLOAT BOOL READ WRITE 
%token END
%token <string> ID
%type <fval> exp comando_if atribs comando_read atrib termo fator
%type <ival> expr_logica


%left SUM SUB
%left MULT DIV
%right ATB
%left EQUAL LESS GREATER LEQUAL GEQUAL DIF
%left AND OR
%right NOT

%start programa

%%

programa:
    bloco
	| blocos bloco
;

blocos:
	bloco
	| blocos bloco
;

bloco:
	declaracoes
	| comandos
;

declaracoes: 
	declaracao
	| declaracoes declaracao
;

declaracao:
	INT ID END { add_symbol($2, INT_VAR); }
	| FLOAT ID END { add_symbol($2, FLOAT_VAR); }
	| BOOL ID END { add_symbol($2, BOOL_VAR); }
;

comandos:
	comando
	| comandos comando
;

comando:
	comando_if
	| atribs 
	| comando_read END
	| comando_write END
;

comando_read:
	READ OP ID CP { 
		switch (get_variable_type($3)) {
			case INT_VAR: 
				int auxInt;
				printf("Digite int: ");
				scanf("%d", &auxInt);
				while (getchar() != '\n');
				set_int_value($3, auxInt);
			break;
			case FLOAT_VAR: 
				float auxFloat;
				printf("Digite float: ");
				scanf("%f", &auxFloat);
				while (getchar() != '\n');
				set_float_value($3, auxFloat);
			break;
			case BOOL_VAR: 
				int auxBool;
				printf("Digite booleano: ");
				scanf("%d", &auxBool);
				while (getchar() != '\n');
				set_bool_value($3, auxBool);
			break;
			default:
				break;
		}
	}
;

comando_write:
	WRITE OP exp CP { 
		printf("%f\n", $3); 
	}
;

atribs:
	atrib
;

atrib:
	ID ATB exp END { 
		switch (get_variable_type($1)) {
			case INT_VAR: 
				set_int_value($1, $3);
			break;
			case FLOAT_VAR: 
				set_float_value($1, $3);
			break;
			break;
			default:
				// variable not found
				break;
		} }
	| ID ATB expr_logica END {
		switch (get_variable_type($1)) {
			case BOOL_VAR: 
				set_bool_value($1, $3);
			break;
			default:
				// variable not found
				break;
		} }
;

exp:
    termo
    | exp SUM termo      { $$ = $1 + $3; }
    | exp SUB termo     { $$ = $1 - $3; }
;

termo:
    fator
    | termo MULT fator      { $$ = $1 * $3; }
    | termo DIV fator        { $$ = $1 / $3; }
;

fator:
    NUM
	| ID { 
		switch (get_variable_type($1)) {
			case INT_VAR: 
				$$ = get_int_value($1);
			break;
			case FLOAT_VAR: 
				$$ = get_float_value($1);
			break;
			case BOOL_VAR: 
				$$ = get_bool_value($1);
			break;
			default:
				// variable not found
				break;
		}
	}
    | OP exp CP { $$ = $2; }
;

expr_logica:
	BTRUE              { $$ = 1; }
	| BFALSE           { $$ = 0; }
	| NOT expr_logica { $$ = !$2; }
  	| exp EQUAL exp { $$ = $1 == $3; }
	| exp LEQUAL exp { $$ = $1 <= $3; }
	| exp GEQUAL exp { $$ = $1 >= $3; }
	| exp DIF exp { $$ = $1 != $3; }
	| exp LESS exp { $$ = $1 < $3; }
	| exp GREATER exp { $$ = $1 > $3; }
	| exp OR exp { $$ = $1 || $3; }
	| exp AND exp { $$ = $1 && $3; }
;

comando_if:
	IF OP expr_logica CP 
	OB atribs CB
	ELSE OB atribs CB { if ($3) { $$ = $6; } else { $$ = $10; } } 
	| IF OP expr_logica CP
	OB atribs CB { if ($3) { $$ = $6; } }
;
/* End of grammar. */
%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
