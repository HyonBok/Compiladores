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
	Temp* temp;
}

%token <fval> NUM
%token SUM SUB MULT DIV ATB
%token IF ELSE 
%token EQUAL LESS GREATER LEQUAL DIF GEQUAL AND OR NOT 
%token OB CB OP CP
%token BTRUE BFALSE
%token INT FLOAT BOOL /* READ */ WRITE 
%token END
%token <string> ID
%type <fval> comando_if /* comando_read */ atrib 
%type <temp> termo fator exp
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
	| INT ID ATB exp END { add_symbol($2, INT_VAR); set_int_value($2, $4.value); printf("t%f = %f", $4.index, $4.value); }
	| FLOAT ID END { add_symbol($2, FLOAT_VAR); }
	| FLOAT ID ATB exp END { add_symbol($2, FLOAT_VAR); set_float_value($2, $4.value); }
	| BOOL ID END { add_symbol($2, BOOL_VAR); }
	| BOOL ID ATB expr_logica END { add_symbol($2, BOOL_VAR); set_bool_value($2, $4.value); }
;

comandos:
	comando
	| comandos comando
;

comando:
	comando_if
	| atrib 
	// | comando_read END
	| comando_write END
;

comando_if:
	IF OP expr_logica CP
	OB atrib CB
	ELSE OB atrib CB { if ($3) { $$ = $6; } else { $$ = $10; } } 
	| IF OP expr_logica CP
	OB atrib CB { if ($3) { $$ = $6; } }
;

/*
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
*/

comando_write:
	WRITE OP exp CP { 
		printf("%f\n", $3.value); 
	}
;

atrib:
	ID ATB exp END { 
		switch (get_variable_type($1)) {
			case INT_VAR: 
				set_int_value($1, $3.value);
			break;
			case FLOAT_VAR: 
				set_float_value($1, $3.value);
			break;
			break;
			default:
				// variable not found
				break;
		} }
	| ID ATB expr_logica END {
		switch (get_variable_type($1)) {
			case BOOL_VAR: 
				set_bool_value($1, $3.value);
			break;
			default:
				// variable not found
				break;
		} }
;

exp:
    termo
    | exp SUM exp { /* $$ = $1 + $3; */ $$ = add_temp($1.value + $3.value); printf("t%f = %f + %f\n", $$.index, $1.value, $3.value); }
    | exp SUB exp { /* $$ = $1 - $3; */ $$ = add_temp($1.value - $3.value); printf("t%f = %f - %f\n", $$.index, $1.value, $3.value); }
;

termo:
    fator
    | termo MULT termo { /* $$ = $1 * $3; */ $$ = add_temp($1.value * $3.value); printf("t%f = %f * %f\n", $$.index, $1.value, $3.value); }
    | termo DIV termo { /* $$ = $1 / $3; */ $$ = add_temp($1.value / $3.value); printf("t%f = %f / %f\n", $$.index, $1.value, $3.value); }

fator:
    NUM { $$ = add_temp($1); }
	| ID { $$ = get_temp($1); }
    | OP exp CP { $$ = $2; }
;

expr_logica:
	BTRUE { $$ = 1; }
	| BFALSE { $$ = 0; }
	| NOT expr_logica { $$ = !$2; }
  	| exp EQUAL exp { $$ = $1.value == $3.value; }
	| exp LEQUAL exp { $$ = $1.value <= $3.value; }
	| exp GEQUAL exp { $$ = $1.value >= $3.value; }
	| exp DIF exp { $$ = $1.value != $3.value; }
	| exp LESS exp { $$ = $1.value < $3.value; }
	| exp GREATER exp { $$ = $1.value > $3.value; }
	| exp OR exp { $$ = $1.value || $3.value; }
	| exp AND exp { $$ = $1.value && $3.value; }
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
