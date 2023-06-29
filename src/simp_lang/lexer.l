%option noyywrap

%{
  #include <simp_lang/simp_lang.h>
  #include "parser.tab.h"
%}

%%

[ \t\n] ; // ignore all whitespace and newline characters
[0-9]+ {yylval.ival = atoi(yytext); return NUMBER;}
"IF" { return IF;}
"THEN" { return THEN;}
"ELSE" { return ELSE;}
"END" { return END;}
"REPEAT" { return REPEAT;}
"UNTIL" { return UNTIL;}
"READ" { return READ;}
"WRITE" { return WRITE;}
[a-zA-Z][a-zA-Z0-9]* {
    char *str = malloc(strlen(yytext) + 1);
    strcpy(str, yytext);
    yylval.sval = str;
    return ID;
}
"+" { return ADDOP;}
"-" { return SUBOP;}
"*" { return MULOP;}
"/" { return DIVOP;}
"=" { return EQUAL;}
"<" { return LESS;}
"(" { return LPAREN;}
")" { return RPAREN;}
";" { return SEMI;}
":=" { return ASSIGN;}
%%
