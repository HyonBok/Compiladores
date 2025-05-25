%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h" 
#include "tiny.tab.h"
#include "tiny.tab.h"
#include "symbol.h"
%}

%option noinput
%option noyywrap

%%

"/*".*"*/"                                  ;
"//".*[\n]                                  ;
[+-]?[0-9]+                                 { /* printf("NUMI "); */ yylval.fval = atof(yytext); return NUM; }
INT                                         { /* printf("INT "); */ return INT; }
WRITE                                       { /* printf("WRITE "); */ return WRITE; }
ELSE                                        { /* printf("ELSE "); */ return ELSE; }
IF                                          { /* printf("IF "); */ return IF; }
"+"                                         { /* printf("SUM "); */ return SUM; }
"-"                                         { /* printf("SUB "); */ return SUB; }
"*"                                         { /* printf("MULT "); */ return MULT; }
"/"                                         { /* printf("DIV "); */ return DIV; }
"="                                         { /* printf("ATB "); */ return ATB; }
">"                                         { /* printf("GREATER "); */ return GREATER; }
"<"                                         { /* printf("LESS "); */ return LESS; }
">="                                        { /* printf("GEQUAL "); */ return GEQUAL; }
"<="                                        { /* printf("LEQUAL "); */ return LEQUAL; }
"=="                                        { /* printf("EQUAL "); */ return EQUAL; }
"!="                                        { /* printf("DIF "); */ return DIF; }
"("                                         { /* printf("OP "); */ return OP; }
")"                                         { /* printf("CP "); */ return CP; }
"{"                                         { /* printf("OB\n "); */ return OB; }
"}"                                         { /* printf("CB\n "); */ return CB; }
";"                                         { /* printf("END\n "); */ return END; }
[a-zA-Z_][a-zA-Z0-9_]{0,9}                  { /* printf("ID "); */ yylval.string = strdup(yytext); return ID; }
[ \t\n]                                     ;
.                                           ;

%%