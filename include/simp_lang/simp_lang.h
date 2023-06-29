#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>

#define YY_DECL int yylex()

extern int yylex();
extern int yyparse();
extern int fileno(FILE* file);
extern FILE* yyin;
void yyerror(const char* s);
extern int yylineno;
extern char *yytext;
extern int yydebug;

typedef struct {
  char* code;
  char* label;
  // Transient code
  char* tcode;
} Node;

char* create_label();
char* create_reg();
char* create_str(const char* str);
char* create_strf(const char* format, ...);

void trim_start(char* str);
void trim_end(char* str);
void append_str(char* str, const char* append);
void indent_code(char* code);

void simp_parse(FILE* from);
