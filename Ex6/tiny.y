%{
  #include <stdio.h> 
  #include <math.h>  
  #include "symbol.h"  
  extern FILE *yyin; 
  int yylex (void);
  void yyerror (char const *);

  char textoFinal[1000];
%}

%union {
    int ival;
    float fval;
    char cval;
	char* string;
	Temp* temp;
	Campo* campo;
}

%token <fval> NUM
%token SUM SUB MULT DIV ATB
%token IF ELSE 
%token EQUAL LESS GREATER LEQUAL DIF GEQUAL /*AND OR NOT */
%token OB CB OP CP
//%token BTRUE BFALSE
%token INT WRITE
%token END
%token <string> ID
%type <campo> expr_logica 
%type <temp> termo fator exp


%left SUM SUB
%left MULT DIV
%right ATB
%left EQUAL LESS GREATER LEQUAL GEQUAL DIF
//%left AND OR
//%right NOT

%start programa

%%

programa:
    bloco { printf("%s\n", textoFinal); }
	| blocos bloco { printf("%s\n", textoFinal); }
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
	INT ID END { add_symbol($2, INT_VAR, -1); }
	| INT ID ATB exp END { 
		add_symbol($2, INT_VAR, $4->index);
		Temp* t = get_temp_from_symbol($2);
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($4->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d\n", t->index, $4->value);
			$4->unique = 0;
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d\n", t->index, $4->index); 
		}
	}
;

comandos:
	comando
	| comandos comando
;

comando:
	comando_if
	| atrib 
	| comando_write END
;

comando_if:
	IF OP expr_logica CP OB atrib CB ELSE OB atrib CB { 
		
	} 
	| IF OP expr_logica CP OB atrib CB { 
		//printf("if %d goto %d\n", get_line());
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		memmove(&textoFinal[$3 + 3], &textoFinal[$3], strlen(&textoFinal[$3]) + 1);
		memcpy(textoFinal + $3, "if ", 3);
	}
;

comando_write:
	WRITE OP exp CP { 
		//printf("%d\n", $3->value); 
	}
;

atrib:
	ID ATB exp END { 
		switch (get_variable_type($1)) {
			case INT_VAR: 
				Temp* t = get_temp_from_symbol($1);
				int lenTextoFinal = strlen(textoFinal);
				int espaco = sizeof(textoFinal) - lenTextoFinal;
				if($3->unique == 1){
					snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d\n", t->index, $3->value);
				}
				else{
					snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d\n", t->index, $3->value);
				}
				
				break;
			default:
				// variable not found
				break;
			} 
		}
;

exp:
    termo
    | exp SUM exp { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value + $3->value, 0); 
			if($1->unique == 1 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d + %d\n", $$->index, $1->value, $3->value);
			}
			else if($1->unique == 0 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d + %d\n", $$->index, $1->index, $3->value);
			}
			else if($1->unique == 1 && $3->unique == 0){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d + t%d\n", $$->index, $1->value, $3->index);
			}
			else{
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d + t%d\n", $$->index, $1->index, $3->index);
			}

		}
    | exp SUB exp { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value - $3->value, 0); 
			if($1->unique == 1 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d - %d\n", $$->index, $1->value, $3->value);
			}
			else if($1->unique == 0 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d - %d\n", $$->index, $1->index, $3->value);
			}
			else if($1->unique == 1 && $3->unique == 0){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d - t%d\n", $$->index, $1->value, $3->index);
			}
			else{
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d - t%d\n", $$->index, $1->index, $3->index);
			}

		}
;

termo:
    fator
    | termo MULT termo { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value * $3->value, 0); 
			if($1->unique == 1 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d * %d\n", $$->index, $1->value, $3->value); 
			}
			else if($1->unique == 0 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d * %d\n", $$->index, $1->index, $3->value);
			}
			else if($1->unique == 1 && $3->unique == 0){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d * t%d\n", $$->index, $1->value, $3->index);
			}
			else{
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d * t%d\n", $$->index, $1->index, $3->index);
			}

		}
    | termo DIV termo { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value / $3->value, 0); 
			if($1->unique == 1 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d / %d\n", $$->index, $1->value, $3->value); 
			}
			else if($1->unique == 0 && $3->unique == 1){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d / %d\n", $$->index, $1->index, $3->value);
			}
			else if($1->unique == 1 && $3->unique == 0){
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d / t%d\n", $$->index, $1->value, $3->index);
			}
			else{
				snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d / t%d\n", $$->index, $1->index, $3->index);
			}

		}

fator:
    NUM { $$ = add_temp($1, 1); }
	| ID { $$ = get_temp_from_symbol($1); }
    | OP exp CP { $$ = $2; }
;

expr_logica:
/*
	BTRUE { $$ = 1; }
	| BFALSE { $$ = 0; }
	| NOT expr_logica { $$ = !$2; }
  	|*/ exp EQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($1->unique == 1 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d == %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d == %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d == t%d ", $1->value, $3->index); 
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d == t%d ", $1->index, $3->index); 
		}
	}
	| exp LEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		$$ = lenTextoFinal;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($1->unique == 1 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d <= %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d <= %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d <= t%d ", $1->value, $3->index); 
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d <= t%d ", $1->index, $3->index); 
		}
	 }
	| exp GEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		$$ = lenTextoFinal;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($1->unique == 1 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d >= %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d >= %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d >= t%d ", $1->value, $3->index); 
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d >= t%d ", $1->index, $3->index); 
		}
	 }
	| exp DIF exp { 
		int lenTextoFinal = strlen(textoFinal);
		$$ = lenTextoFinal;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($1->unique == 1 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d != %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d != %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d != t%d ", $1->value, $3->index); 
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d != t%d ", $1->index, $3->index); 
		}
	 }
	| exp LESS exp { 
		int lenTextoFinal = strlen(textoFinal);
		$$ = lenTextoFinal;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($1->unique == 1 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d < %d\n", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d < %d\n", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d < t%d\n", $1->value, $3->index); 
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d < t%d\n", $1->index, $3->index); 
		}
	 }
	| exp GREATER exp { 
		int lenTextoFinal = strlen(textoFinal);
		$$ = lenTextoFinal;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		if($1->unique == 1 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d > %d\n", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d > %d\n", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			snprintf(textoFinal + lenTextoFinal, espaco, "%d > t%d\n", $1->value, $3->index); 
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d > t%d\n", $1->index, $3->index); 
		}
	 }
	 /*
	| expr_logica OR expr_logica { 
		if($1->unique == 1 && $3->unique == 1){
			printf("%d || %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			printf("t%d || %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			printf("%d || t%d ", $1->value, $3->index); 
		}
		else{
			printf("t%d || t%d ", $1->index, $3->index); 
		}
	 }
	| expr_logica AND expr_logica { 
		if($1->unique == 1 && $3->unique == 1){
			printf("%d && %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			printf("t%d && %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			printf("%d && t%d ", $1->value, $3->index); 
		}
		else{
			printf("t%d && t%d ", $1->index, $3->index); 
		}
	 }
	 */
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
