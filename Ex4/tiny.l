%{
#include "tiny.tab.h"
%}

%%

[0-9]+(\.[0-9]+)?       { yylval.fval = atof(yytext); return NUM; }
[a-z]                   { yylval.cval = yytext[0]; return VAR; }
SENAO                   { return SENAO; }
SE                      { return SE; }
[+]                     { return SOMA; }
[-]                     { return SUB; }
[*]                     { return MUL; }
[/]                     { return DIV; }
[=]                     { return ATB; }
[>]                     { return MAIOR; }
[<]                     { return MENOR; }
>=                      { return MAIORIGUAL; }
<=                      { return MENORIGUAL; }
==                      { return IGUAL; }
!=                      { return DIF; }
OU                      { return OU; }
E                       { return E; }
NAO                     { return NAO; }
\(                      { return APARENT; }
\)                      { return FPARENT; }
\{                      { return ACHAVE; }
\}                      { return FCHAVE; }
"//".*[\n]              ;
"/*".*"*/"              ;
[.]                     ;

%%