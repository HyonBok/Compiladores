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
[Ii][Nn][Tt]                                { /* printf("INT "); */ return INT; }
[Ii][Ff]                                    { /* printf("IF "); */ return IF; }
[Ee][Ll][Ss][Ee]                            { /* printf("ELSE "); */ return ELSE; }
[Tt][Rr][Uu][Ee]                            { /* printf("TRUE "); */ return BTRUE; }
[Ff][Aa][Ll][Ss][Ee]                        { /* printf("FALSE "); */ return BFALSE; }
[Aa][Nn][Dd]                                { /* printf("FALSE "); */ return AND; }
[Oo][Rr]                                    { /* printf("FALSE "); */ return OR; }
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
"!"                                        { /* printf("NOT "); */ return NOT; }
"("                                         { /* printf("OP "); */ return OP; }
")"                                         { /* printf("CP "); */ return CP; }
"{"                                         { /* printf("OB\n "); */ return OB; }
"}"                                         { /* printf("CB\n "); */ return CB; }
";"                                         { /* printf("END\n "); */ return END; }
[a-zA-Z_][a-zA-Z0-9_]{0,9}                  { /* printf("ID "); */ yylval.string = strdup(yytext); return ID; }
[ \t\n]                                     ;
.                                           ;

%%