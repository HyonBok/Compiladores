%option noyywrap 
%{
#include <stdio.h> 
#include <stdlib.h> 
enum { TOKEN_IDENT, TOKEN_INT, TOKEN_MISC, TOKEN_EOF }; 
int este_int; 
%}

%% 

[a-zA-Z_][a-zA-Z0-9_]*      return TOKEN_IDENT; 
[+-]?[0-9]+                 { este_int = atoi(yytext);  return TOKEN_INT; } 
.|\r|\n                     return TOKEN_MISC; 
<<EOF>>                     return TOKEN_EOF; 

%% 

int main() 
{ 
    int num_idents = 0; 
    long soma_total = 0L; 
    int token; 
    do { 
    switch( token=yylex() ) { 
        case TOKEN_IDENT: 
            ++num_idents; 
            break; 
        case TOKEN_INT:  
            soma_total += este_int; 
            break; 
        /* outro TOKEN_*: ignorar */ 
        } 
    } 
    while( token != TOKEN_EOF ); 
    printf( "Identificadores: %d\n", num_idents ); 
    printf( "Soma dos inteiros: %ld\n", soma_total ); 
    return 0; 
} 