%{
#include "tiny.tab.h"
%}

%%

[0-9]+(\.[0-9]+)?       { yylval.fval = atof(yytext); return NUM; }
[a-z]                   { yylval.cval = yytext[0]; return VAR; }
ELSE                    { return ELSE; }
IF                      { return IF; }
[+]                     { return SUM; }
[-]                     { return SUB; }
[*]                     { return MUL; }
[/]                     { return DIV; }
[=]                     { return ATB; }
[>]                     { return GREATER; }
[<]                     { return LESS; }
">="                    { return GEQUAL; }
"<="                    { return LEQUAL; }
"=="                    { return EQUAL; }
"!="                    { return DIF; }
"OR"                    { return OR; }
"AND"                   { return AND; }
"NOT"                   { return NOT; }
"TRUE"                  { return TRUE; }
"FALSE"                 { return FALSE; }
"("                     { return OPARENT; }
")"                     { return CPARENT; }
"{"                     { return OBRACKET; }
"}"                     { return CBRACKET; }
"//".*[\n]              ;
"/*".*"*/"              ;
[.]                     ;

%%