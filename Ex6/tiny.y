%{
  #include <stdio.h> 
  #include <math.h>  
  #include "symbol.h"  
  extern FILE *yyin; 
  int yylex (void);
  void yyerror (char const *);

  char textoFinal[1000];
  char textoAuxiliar[100];

  int get_tamanho(int value){
	sprintf(textoAuxiliar, "%d", value);
	return strlen(textoAuxiliar);
  }
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
%token EQUAL /* LESS GREATER LEQUAL DIF GEQUAL /*AND OR NOT */
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
%left EQUAL /* LESS GREATER LEQUAL GEQUAL DIF */
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
	INT ID END { 
		add_symbol($2, INT_VAR);
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = 0\n", $2->name);
		add_line(); 
	}
	| INT ID ATB exp END { 
		add_symbol($2, INT_VAR);
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s\n", $2->name, $4->value);
		/*
		if($4->unique == 1){
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d = %d\n", t->index, $4->value);
			$4->unique = 0;
		}
		else{
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d = t%d\n", t->index, $4->index); 
		}
		*/
	}
;

comandos:
	comando
	| comandos comando
;

comando:
	comando_if
	| atrib 
;

comando_if:
	IF OP expr_logica CP OB atrib CB { 
		int origem = $3->inicio;
		int destino = origem + 3;
		memmove(&textoFinal[destino], &textoFinal[origem], 1000);
		memcpy(textoFinal + origem, "if ", 3);
		
		int casoSe = $3->linha + 4;
		int casoSenao = get_line() + 3;
		snprintf(textoAuxiliar, sizeof(textoAuxiliar), "goto %d\ngoto %d\n", casoSe, casoSenao);
		int tamanhoGoto = strlen(textoAuxiliar);
		origem += $3->tamanho;
		destino = origem + tamanhoGoto;
		int bytes_a_mover = strlen(&textoFinal[origem]) + 1; 
		memmove(&textoFinal[destino], &textoFinal[origem], bytes_a_mover);
		memcpy(textoFinal + origem + 2, textoAuxiliar, tamanhoGoto);
		add_line();
	}
;

atrib:
	ID ATB exp END { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %d\n", $1, $3->value);
		add_line();
	}
;

exp:
    termo
    | exp SUM exp { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value + $3->value, 0); 
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s + %s\n", $$->name, $1->name, $3->value);
			/*
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
			*/
			add_line();
		}
    | exp SUB exp { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value - $3->value, 0); 
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s - %s\n", $$->name, $1->name, $3->name);
			/*
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
			*/
			add_line();
			
		}
;

termo:
    fator
    | termo MULT termo { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value * $3->value, 0); 
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s * %s\n", $$->name, $1->name, $3->name);
			/*
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
			*/
			add_line();
		}
    | termo DIV termo { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp($1->value / $3->value, 0);
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s / %s\n", $$->name, $1->name, $3->name); 
			/*
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
			*/
			add_line();
			
		}

fator:
    NUM { $$ = add_temp(itoa($1), 1); }
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
		int tamanho = 6;
		
		tamanho += get_tamanho(atoi($1->value));
		tamanho += get_tamanho(atoi($3->value));
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s == %s ", $1->value, $3->value); 
			/*
		if($1->unique == 1 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d == %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d == %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d == t%d ", $1->value, $3->index); 
		}
		else{
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d == t%d ", $1->index, $3->index); 
		}
		*/
		$$ = add_campo(lenTextoFinal, tamanho);
		
		add_line();
	}/*
	| exp LEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;

		if($1->unique == 1 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value));
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d <= %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d <= %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d <= t%d ", $1->value, $3->index); 
		}
		else{
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d <= t%d ", $1->index, $3->index); 
		}

		$$ = add_campo(lenTextoFinal, tamanho);
		add_line();
	 }
	| exp GEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;
		
		if($1->unique == 1 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d >= %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d >= %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d >= t%d ", $1->value, $3->index); 
		}
		else{
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d >= t%d ", $1->index, $3->index); 
		}

		$$ = add_campo(lenTextoFinal, tamanho);
		add_line();
	 }
	| exp DIF exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;

		if($1->unique == 1 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d != %d ", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d != %d ", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d != t%d ", $1->value, $3->index); 
		}
		else{
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d != t%d ", $1->index, $3->index); 
		}

		$$ = add_campo(lenTextoFinal, tamanho);
		add_line();
	 }
	| exp LESS exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;

		if($1->unique == 1 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d < %d\n", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d < %d\n", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d < t%d\n", $1->value, $3->index); 
		}
		else{
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d < t%d\n", $1->index, $3->index); 
		}

		$$ = add_campo(lenTextoFinal, tamanho);
		add_line();
	 }
	| exp GREATER exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;
		
		if($1->unique == 1 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d > %d\n", $1->value, $3->value); 
		}
		else if($1->unique == 0 && $3->unique == 1){
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value))
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d > %d\n", $1->index, $3->value); 
		}
		else if($1->unique == 1 && $3->unique == 0){
			
			tamanho += get_tamanho(atoi($1->value));
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "%d > t%d\n", $1->value, $3->index); 
		}
		else{
			
			tamanho += get_tamanho(atoi($1->value)) + 1;
			tamanho += get_tamanho(atoi($3->value)) + 1;
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			snprintf(textoFinal + lenTextoFinal, espaco, "t%d > t%d\n", $1->index, $3->index); 
		}

		$$ = add_campo(lenTextoFinal, tamanho);
		add_line();
	 }*/
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
