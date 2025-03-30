%{
#include <stdio.h> 
#include <stdlib.h> 
float a; 
float b; 
float r;
enum { NUM, SOMA, SUB, MULT, DIV, MISC, TOKEN_EOF }; 
%}

%% 

[+-]?[0-9]+(\.[0-9]+)?     return NUM; 
[+]             return SOMA;
[-]             return SUB;
[*]             return MULT;
[/]             return DIV;
.|\r|\n         return MISC; 
<<EOF>>         return TOKEN_EOF; 

%% 
int main() 
{ 
  int token; 
  do { 
    switch( token=yylex() ) { 
      case NUM: 
        a = b;  
        b = atof(yytext);
        break; 
      case SOMA:  
        r=a+b;
        printf("%f+%f=%f\n", a,b,r);
        b=r;
        break; 
      case SUB:
        r=a-b;
        printf("%f-%f=%f\n", a,b,r);
        b=r;
        break;
      case MULT:
        r=a*b;
        printf("%f*%f=%f\n", a,b,r);
        b=r;
        break;
      case DIV:
        r=a/b;
        printf("%f/%f=%f\n", a,b,r);
        b=r;
        break;
      /* outro TOKEN_*: ignorar */ 
      } 
    } 
    while( token != TOKEN_EOF ); 
    printf( "Resultado: %f\n", r ); 
    return 0; 
} 