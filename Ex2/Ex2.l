%{
#include <stdio.h> 
#include <stdlib.h> 
#define TAM 50
enum { SOMA, SUB, MULT, DIV, MISC, TOKEN_EOF }; 

typedef struct {
  int top;
  float items[TAM];
} Pilha;

void init(Pilha *p) {
    p->top = -1;
}

void push(Pilha *p, float f){
  if(p->top >= TAM - 1){
    printf("Pilha cheia!\n");
    return;
  }
  p->top++;
  p->items[p->top] = f;
}

float pop(Pilha *p){
  if(p->top <= -1){
    printf("Pilha vazia!\n");
    return 0;
  }
  p->top--;
  return p->items[p->top+1];
}

Pilha p;

%}

%% 

[+-]?[0-9]+(\.[0-9]+)?      { push(&p, atof(yytext)); }
[+]                         return SOMA;
[-]                         return SUB;
[*]                         return MULT;
[/]                         return DIV;
.|\r|\n                     return MISC; 
<<EOF>>                     return TOKEN_EOF; 

%% 
int main() 
{ 
  int token; 
  init(&p);
  float a, b, r;

  do { 
    switch( token=yylex() ) { 
      case SOMA: 
        a = pop(&p);
        b = pop(&p);
        r = b + a;
        push(&p, r);
        printf("Soma: %f+%f=%f\n", b,a,r);
        break; 
      case SUB:
        a = pop(&p);
        b = pop(&p);
        r = b - a;
        push(&p, r);
        printf("Subtracao: %f-%f=%f\n", b,a,r);
        break; 
      case MULT:
        a = pop(&p);
        b = pop(&p);
        r = b * a;
        push(&p, r);
        printf("Multiplicacao: %f*%f=%f\n", b,a,r);
        break; 
      case DIV:
        a = pop(&p);
        b = pop(&p);
        r = b / a;
        push(&p, r);
        printf("Divisao: %f/%f=%f\n", b,a,r);
        break; 
      /* outro TOKEN_*: ignorar */ 
      } 
    } 
    while( token != TOKEN_EOF ); 
    printf( "Resultado: %f\n", r ); 
    return 0; 
} 