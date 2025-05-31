%{
  #include <stdio.h> 
  #include <math.h>  
  #include "symbol.h"  
  extern FILE *yyin; 
  int yylex (void);
  void yyerror (char const *);

  char textoFinal[5000];
  char textoAuxiliar[100];

  int global_line = 1;
  // Encadear até 10 if's
  int origem_if[10] = {0};
  int camada_else = 0;
  int pos_then;
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
%token INT
%token END
%token <string> ID
%type <string> termo fator exp expr_logica


%left SUM SUB
%left MULT DIV
%right ATB
%left EQUAL LESS GREATER LEQUAL GEQUAL DIF
%left AND OR
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
	| atribs 
;

comando_if:
	IF OP expr_logica CP { 
		int if_atual = 0;
		while(origem_if[if_atual] != 0){
			if_atual++;
		}
		int casoSe = global_line + if_atual + 2;
		origem_if[if_atual] = strlen(textoFinal);
		int tamanho_condicao = strlen($3);
		int tamanho_if = tamanho_condicao + 3;
		int pos_insercao_if = origem_if[if_atual] + tamanho_if;

		memmove(&textoFinal[pos_insercao_if], &textoFinal[origem_if[if_atual]], strlen(&textoFinal[origem_if[if_atual]]) + 1);

		snprintf(textoAuxiliar, sizeof(textoAuxiliar), "if %s", $3);
		memcpy(&textoFinal[origem_if[if_atual]], textoAuxiliar, tamanho_if);
		
		snprintf(textoAuxiliar, sizeof(textoAuxiliar), " goto %d\n", casoSe);
		int tamanho_goto = strlen(textoAuxiliar);

		origem_if[if_atual] += tamanho_condicao + 1;
		// Calcula nova posição para inserir o goto
		int pos_insercao_goto = origem_if[if_atual]; // +1 para espaço ou separador
		int pos_final_goto = pos_insercao_goto + tamanho_goto;
		
		// Move o conteúdo para abrir espaço para o goto
		memmove(&textoFinal[pos_final_goto], &textoFinal[pos_insercao_goto], strlen(&textoFinal[pos_insercao_goto]) + 1);
		
		// Insere o goto
		memcpy(&textoFinal[pos_insercao_goto + 2], textoAuxiliar, tamanho_goto);

		origem_if[if_atual] += tamanho_goto;
		
		global_line++;
	} then
;

then:
	OB comandos CB { 
		int if_atual = 9;
		while(if_atual > 0 && origem_if[if_atual] == 0){
			if_atual--;
		}
   		global_line++;
		int casoSenao = global_line + if_atual; 

		snprintf(textoAuxiliar, sizeof(textoAuxiliar), "goto %d\n", casoSenao);
		int tamanho_goto = strlen(textoAuxiliar);

		int pos_insercao_goto = origem_if[if_atual];
		int pos_final_goto = pos_insercao_goto + tamanho_goto;

		memmove(&textoFinal[pos_final_goto], &textoFinal[pos_insercao_goto], strlen(&textoFinal[pos_insercao_goto]) + 1);
		memcpy(&textoFinal[pos_insercao_goto + 2], textoAuxiliar, tamanho_goto);
		origem_if[if_atual] = 0;
	}
	| OB comandos CB ELSE  { 
		int if_atual = 9;
		while(if_atual > 0 && origem_if[if_atual] == 0){
			if_atual--;
		}
   		global_line++;
		int casoSenao = global_line + if_atual + 1; 

		snprintf(textoAuxiliar, sizeof(textoAuxiliar), "goto %d\n", casoSenao);
		int tamanho_goto = strlen(textoAuxiliar);

		int pos_insercao_goto = origem_if[if_atual];
		int pos_final_goto = pos_insercao_goto + tamanho_goto;

		memmove(&textoFinal[pos_final_goto], &textoFinal[pos_insercao_goto], strlen(&textoFinal[pos_insercao_goto]) + 1);
		memcpy(&textoFinal[pos_insercao_goto + 2], textoAuxiliar, tamanho_goto);
		origem_if[if_atual] = 0;

		// Usado posteriormente
		pos_then = strlen(textoFinal);
		camada_else = if_atual;
	} OB comandos CB {
		// Ignorar o else
		// Gerar o texto "goto %d\n"
		global_line++;
		snprintf(textoAuxiliar, sizeof(textoAuxiliar), "goto %d\n", global_line + camada_else);
		int tamanho_goto = strlen(textoAuxiliar);
		int lenTextoFinal = strlen(textoFinal);

		// Mover o conteúdo a partir de pos_then para frente, para abrir espaço
		memmove(&textoFinal[pos_then + tamanho_goto], &textoFinal[pos_then], lenTextoFinal - pos_then + 1); 
		// +1 para mover o '\0'

		// Inserir o texto na posição pos_then
		memcpy(&textoFinal[pos_then], textoAuxiliar, tamanho_goto);
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
	| ID { if(!get_symbol($1)) { yyerror("Variável não declarada"); exit(EXIT_FAILURE); } }
	| OP exp CP { $$ = $2; }
;

expr_logica:
	exp { 
		$$ = $1;
	}
	| BTRUE { 
		$$ = add_temp(1, 1);
	}
	| BFALSE { 
		$$ = add_temp(0, 1);
	}
	| NOT expr_logica { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = !%s\n", $$, $2); 
		global_line++;
	}
  	| exp EQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s == %s\n", $$, $1, $3); 
		global_line++;
	}
	| exp LEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s <= %s\n", $$, $1, $3); 
		global_line++;
	 }
	| exp GEQUAL exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s >= %s\n", $$, $1, $3); 
		global_line++;
	 }
	| exp DIF exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s != %s\n", $$, $1, $3); 
		global_line++;
	 }
	| exp LESS exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s < %s\n", $$, $1, $3); 
		global_line++;
	 }
	| exp GREATER exp { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s > %s\n", $$, $1, $3); 
		global_line++;
	 }
	| expr_logica OR expr_logica { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s or %s\n", $$, $1, $3);
		global_line++;
	 }
	| expr_logica AND expr_logica { 
		int lenTextoFinal = strlen(textoFinal);
		int espaco = sizeof(textoFinal) - lenTextoFinal;
		$$ = add_temp(0, 0);
		snprintf(textoFinal + lenTextoFinal, espaco, "%s = %s and %s\n", $$, $1, $3);
		global_line++;
	 }
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
