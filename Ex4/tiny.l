%{
#include "tiny.tab.h"
%}

%%

[0-9]+(\.[0-9]+)?       { yylval.fval = atof(yytext); return NUMBER; }
[a-z]                   { yylval.cval = yytext[0]; return VAR; }
SENAO                   { return SENAO; }
SE                      { return SE; }
ENTAO                   { return ENTAO; }
[+]                     { return ADD; }
[-]                     { return SUB; }
[*]                     { return MUL; }
[/]                     { return DIV; }
[=]                     { return ATB; }
[\(]                    { return LPARENT; }
[\)]                    { return RPARENT; }
[\n]                    { return EOL; }
[. \t\n]                ;

%%