%{
#include "parser.tab.h"
%}

%%

[0-9]+(\.[0-9]+)?       { yylval.fval = atof(yytext); return NUMBER; }
[a-zA-Z]                { yylval.cval = yytext[0]; return VAR; }
[+]                     { return ADD; }
[-]                     { return SUB; }
[*]                     { return MUL; }
[/]                     { return DIV; }
[=]                     { return ATB; }
[ \t]                   ;
[\n]                    { return EOL; }
.                       ;

%%