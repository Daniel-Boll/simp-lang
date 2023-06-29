%{
  #include <simp_lang/simp_lang.h>
%}

%union {
 int ival;
 char* sval;
 Node node;
}

%token<sval> ID
%token<ival> NUMBER
%token IF THEN ELSE END REPEAT UNTIL READ WRITE ASSIGN
%token LESS EQUAL ADDOP SUBOP MULOP DIVOP SEMI LPAREN RPAREN

%type<node> program cmd_seq cmd if_cmd repeat_cmd rel_op add_op mul_op
%type<node> assign_cmd read_cmd write_cmd exp simple_exp
%type<node> term factor

%start program

%%

program:
  cmd_seq {
    // ✅
    printf("main:\n");
    printf("%s\n", $1.code);
    free($1.code);
  }
;

cmd_seq: 
  cmd {
    // ✅
    $$ = $1;
  }
  | cmd_seq SEMI cmd {
    // ✅
    $$.code = create_strf("%s%s", $1.code, $3.code);
    $$.tcode = create_str("");
    $$.label = create_str("");
    free($1.code);
    free($3.code);
  }
;

cmd: if_cmd
 | repeat_cmd
 | assign_cmd
 | read_cmd
 | write_cmd
;

if_cmd: 
  IF exp THEN cmd_seq END {
    char* if_label = create_label();
    char* end_label = create_label();

    trim_end($2.code);
    trim_end($2.tcode);
    trim_end($4.code);

    $$.code = create_strf(
      "%s\n"
      "if (%s) goto %s\n"
      "goto %s\n"
      "%s:\n"
      "%s\n"
      "%s:\n",
      $2.tcode,
      $2.code, if_label, 
      end_label,
      if_label, $4.code,
      end_label
    );
    $$.tcode = create_str("");

    free(if_label);
    free(end_label);
  }
  | IF exp THEN cmd_seq ELSE cmd_seq END {
    char* if_label = create_label();
    char* else_label = create_label();
    char* end_label = create_label();

    trim_end($2.code);
    trim_end($4.code);
    trim_end($6.code);

    $$.code = create_strf(
      "%s"
      "if (%s) goto %s\n"
      "goto %s\n"
      "%s:\n"
      "%s\n"
      "goto %s\n"
      "%s:\n"
      "%s\n"
      "%s:\n",
      $2.tcode,
      $2.code, if_label,
      else_label,
      if_label, $4.code,
      end_label,
      else_label, $6.code,
      end_label
    );
    $$.tcode = create_str("");

    free(if_label);
    free(else_label);
    free(end_label);
  }
;

repeat_cmd:
  REPEAT cmd_seq UNTIL exp {
    char* repeat_label = create_label();
    char* end_label = create_label();

    trim_end($2.code);
    trim_end($2.tcode);
    trim_end($4.code);
    trim_end($4.tcode);
  
    $$.code = create_strf(
      "%s\n"                    // cmd_seq transient code
      "%s:\n"                   // repeat label
      "%s\n"                    // cmd_seq code
      "%s\n"                    // exp transient code
      "if (%s) goto %s\n"       // until exp code; end label
      "goto %s\n"               // goto repeat label
      "%s:\n",                  // end label
      $2.tcode,
      repeat_label,
      $2.code,
      $4.tcode,
      $4.code, end_label,
      repeat_label,
      end_label
    );
    $$.tcode = create_str("");

    free(repeat_label);
    free(end_label);
  }
;

assign_cmd: 
  ID ASSIGN exp {
    // ✅
    trim_end($3.tcode);
    $$.code = create_strf("%s\n%s = %s\n", $3.tcode, $1, $3.code);
    $$.tcode = create_str("");
    $$.label = create_str("");
    free($3.code);
  }
;

read_cmd: 
  READ ID {
    // ✅
    $$.code = create_strf("%s = read()\n", $2);
    $$.tcode = create_str("");
    $$.label = create_str("");
  }
;

write_cmd: 
  WRITE exp {
    // ✅
    trim_end($2.tcode);
    $$.code = create_strf("write(%s)\n", $2.code);
    $$.tcode = create_str("");
    $$.label = create_str("");
  }
;

exp: 
  simple_exp {
    $$ = $1;
  }
  | simple_exp rel_op simple_exp {
    // ✅
    char* reg = create_reg();

    trim_end($1.code);
    trim_end($2.code);
    trim_end($3.code);

    $$.tcode = create_strf("%s%s = %s\n", $1.tcode, reg, $1.code);
    $$.code = create_strf("%s %s %s", reg, $2.code, $3.code);

    free(reg);
    free($1.code);
    free($3.code);
  }
;

simple_exp: 
  term {
    $$ = $1;
  }
  | simple_exp add_op term {
    // ✅
    char* reg = create_reg();

    trim_end($1.tcode);
    trim_end($1.code);
    trim_end($2.code);
    trim_end($3.code);

    $$.tcode = create_strf("%s%s = %s\n", $1.tcode, reg, $1.code);
    $$.code = create_strf("%s %s %s", reg, $2.code, $3.code);

    free(reg);
    free($1.code);
    free($3.code);
  }
;

term: 
  factor {
    $$ = $1;
  }
  | factor mul_op factor {
    // ✅
    char* reg = create_reg();

    trim_end($1.code);
    trim_end($2.code);
    trim_end($3.code);

    $$.tcode = create_strf("%s%s = %s\n", $1.tcode, reg, $1.code);
    $$.code = create_strf("%s %s %s", reg, $2.code, $3.code);

    free(reg);
    free($1.code);
    free($3.code);
  }
;

factor:
  LPAREN exp RPAREN {
    $$ = $2;
  }
  | NUMBER {
    // ✅
    $$.code = create_strf("%d", $1);
    $$.tcode = create_str("");
    $$.label = create_str("");
  }
  | ID {
    // ✅
    $$.code = create_str($1);
    $$.tcode = create_str("");
    $$.label = create_str("");
    free($1);
  }
;

rel_op:
 EQUAL  { $$.code = create_str("="); $$.label = create_str(""); $$.tcode = create_str(""); }
 | LESS { $$.code = create_str("<"); $$.label = create_str(""); $$.tcode = create_str(""); }
;

add_op:
 ADDOP   { $$.code = create_str("+"); $$.label = create_str(""); $$.tcode = create_str(""); }
 | SUBOP { $$.code = create_str("-"); $$.label = create_str(""); $$.tcode = create_str(""); }
;

mul_op:
 MULOP   { $$.code = create_str("*"); $$.label = create_str(""); $$.tcode = create_str(""); }
 | DIVOP { $$.code = create_str("/"); $$.label = create_str(""); $$.tcode = create_str(""); }
;

%%
