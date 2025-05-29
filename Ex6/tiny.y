%{
  #include <stdio.h> 
  #include <math.h>  
  #include "symbol.h"  
  extern FILE *yyin; 
  int yylex (void);
  void yyerror (char const *);

  char textoFinal[1000];
  char textoAuxiliar[100];

  int global_line = 1;
%}

%union {
    int ival;
    float fval;
    char cval;
	char* string;
	Campo* campo;
}

%token <fval> NUM
%token SUM SUB MULT DIV ATB
%token IF ELSE 
%token EQUAL LESS GREATER LEQUAL DIF GEQUAL AND OR NOT
%token OB CB OP CP
%token BTRUE BFALSE
%token INT
%token END
%token <string> ID
%type <campo> expr_logica 
%type <string> termo fator exp


%left SUM SUB
%left MULT DIV
%right ATB
%left EQUAL /* LESS GREATER LEQUAL GEQUAL DIF */
//%left AND OR
%right NOT

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
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = 0\n", $2);
		global_line++; 
	}
	| INT ID ATB exp END { 
		add_symbol($2, INT_VAR);
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s\n", $2, $4);
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
	IF OP expr_logica CP OB atribs CB { 
		int origem = $3->inicio;
		int destino = origem + 3;
		memmove(&textoFinal[destino], &textoFinal[origem], 1000);
		memcpy(textoFinal + origem, "if ", 3);
		
		int casoSe = $3->linha + 4;
		int casoSenao = global_line + 3;
		snprintf(textoAuxiliar, sizeof(textoAuxiliar), "goto %d\ngoto %d\n", casoSe, casoSenao);
		int tamanhoGoto = strlen(textoAuxiliar);
		origem += $3->tamanho;
		destino = origem + tamanhoGoto;
		int bytes_a_mover = strlen(&textoFinal[origem]) + 1; 
		memmove(&textoFinal[destino], &textoFinal[origem], bytes_a_mover);
		memcpy(textoFinal + origem + 2, textoAuxiliar, tamanhoGoto);
		global_line++;
	}
;

atribs:
 	atrib
 	| atribs atrib

atrib:
	ID ATB exp END { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s\n", $1, $3);
		global_line++;
	}
;

exp:
    termo
    | exp SUM exp { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp(0, 0); 
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s + %s\n", $$, $1, $3);
			global_line++;
		}
    | exp SUB exp { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp(0, 0); 
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s - %s\n", $$, $1, $3);
			global_line++;
		}
;

termo:
    fator
    | termo MULT termo { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp(0, 0); 
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s * %s\n", $$, $1, $3);
			global_line++;
		}
    | termo DIV termo { 
			int lenTextoFinal = strlen(textoFinal);
			int espaco = sizeof(textoFinal) - lenTextoFinal;
			$$ = add_temp(0, 0);
			snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s / %s\n", $$, $1, $3); 
			global_line++;
		}

fator:
    NUM { $$ = add_temp($1, 1); }
	| ID
    | OP exp CP { $$ = $2; }
;

expr_logica:
	BTRUE { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "TRUE ");
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	}
	| BFALSE { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 7;
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "FALSE ");
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	}/*
	| NOT expr_logica { 
		int lenTextoFinal = strlen(textoFinal);
		memmove(textoFinal + lenTextoFinal,
        		textoFinal + lenTextoFinal + tamanho,
        		strlen(textoFinal + lenTextoFinal + tamanho) + 1);
	}*/
  	| exp EQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;
		
		tamanho += strlen($1) + strlen($3);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s == %s ", $1, $3);
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	}
	| exp LEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;
		
		tamanho += strlen($1) + strlen($3);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s <= %s ", $1, $3);
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	 }
	| exp GEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;

		tamanho += strlen($1) + strlen($3);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s >= %s ", $1, $3);
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	 }
	| exp DIF exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 6;

		tamanho += strlen($1) + strlen($3);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s != %s ", $1, $3);
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	 }
	| exp LESS exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 5;

		tamanho += strlen($1) + strlen($3);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s < %s ", $1, $3);
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
	 }
	| exp GREATER exp { 
		int lenTextoFinal = strlen(textoFinal);
		int tamanho = 5;

		tamanho += strlen($1) + strlen($3);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		snprintf(textoFinal + lenTextoFinal, espaco, "%s > %s ", $1, $3);
		$$ = add_campo(lenTextoFinal, tamanho, global_line);
		
		global_line++;
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
