#include <simp_lang/simp_lang.h>

static int reg_counter = 0;
static int label_counter = 0;

#define BUFFER_SIZE 1024

char* create_label() {
  char* label = (char*)malloc(snprintf(NULL, 0, "L%d", label_counter) + 1);
  sprintf(label, "L%d", label_counter++);
  return label;
}

char* create_reg() {
  char* reg = (char*)malloc(snprintf(NULL, 0, "T%d", reg_counter) + 1);
  sprintf(reg, "T%d", reg_counter++);
  return reg;
}

char* create_str(const char* str) {
  if (str == NULL) {
    fprintf(stderr, "create_str: NULL argument\n");
    return NULL;
  }

  size_t str_len = strlen(str);
  char* result = (char*)malloc(str_len + 1);
  if (result == NULL) {
    fprintf(stderr, "create_str: malloc failed\n");
    exit(EXIT_FAILURE);
  }

  strcpy(result, str);
  return result;
}

char* create_strf(const char* format, ...) {
  if (format == NULL) {
    fprintf(stderr, "create_strf: NULL format argument\n");
    return NULL;
  }

  va_list args;
  va_start(args, format);

  // Check for NULL arguments among variable arguments
  const char* arg;
  while ((arg = va_arg(args, const char*)) != NULL) {
    if (arg == NULL) {
      fprintf(stderr, "create_strf: NULL argument\n");
      va_end(args);
      return "";
    }
  }

  va_end(args);

  va_start(args, format);
  size_t str_len = vsnprintf(NULL, 0, format, args);
  va_end(args);

  char* result = (char*)malloc(str_len + 1);
  if (result == NULL) {
    fprintf(stderr, "create_strf: malloc failed\n");
    exit(EXIT_FAILURE);
  }

  va_start(args, format);
  vsprintf(result, format, args);
  va_end(args);

  return result;
}

void trim_start(char* str) {
  if (str == NULL) {
    fprintf(stderr, "trim_start: NULL argument\n");
    return;
  }
  int i = 0, j = 0;
  while (str[i] == ' ' || str[i] == '\t' || str[i] == '\n') i++;
  while (str[i] != '\0') str[j++] = str[i++];
  str[j] = '\0';
}

void trim_end(char* str) {
  if (str == NULL) {
    // fprintf(stderr, "trim_end: NULL argument\n");
    str = (char*)malloc(1);
    str[0] = '\0';
    return;
  }
  int i = strlen(str) - 1;
  while (str[i] == ' ' || str[i] == '\t' || str[i] == '\n') i--;
  str[i + 1] = '\0';
}

void append_str(char* str, const char* append) {
  if (str == NULL || append == NULL) {
    fprintf(stderr, "append_str: NULL argument\n");
    return;
  }

  size_t str_len = strlen(str);
  size_t append_len = strlen(append);
  size_t new_len = str_len + append_len;

  // Ensure enough space in the buffer (including null terminator)
  if (new_len + 1 > BUFFER_SIZE) {
    fprintf(stderr, "append_str: buffer overflow\n");
    return;
  }

  memcpy(str + str_len, append, append_len + 1);  // Append the string
}

void indent_code(char* code) {
  const int INDENT_SIZE = 2;
  const int MAX_CODE_LENGTH = 1000;
  char formattedCode[MAX_CODE_LENGTH];
  int indentLevel = 0;
  int index = 0;
  int i;

  // Remove extra spaces and empty lines
  for (i = 0; code[i] != '\0'; i++) {
    if (code[i] == ' ' && (code[i + 1] == ' ' || code[i + 1] == '\n')) continue;
    if (code[i] == '\n' && (code[i + 1] == '\n' || code[i + 1] == '\0')) continue;
    formattedCode[index++] = code[i];
  }
  formattedCode[index] = '\0';

  // Indent the code
  index = 0;
  while (formattedCode[index] != '\0') {
    if (formattedCode[index] == '\n') {
      int j;
      for (j = 0; j < indentLevel * INDENT_SIZE; j++) {
        printf(" ");
      }
    }
    printf("%c", formattedCode[index]);

    if (formattedCode[index] == ':') {
      indentLevel++;
    } else if (formattedCode[index] == '\n') {
      int j = index + 1;
      while (formattedCode[j] == ' ') j++;
      if (formattedCode[j] == '\0' || formattedCode[j] == ':') indentLevel--;
    }

    index++;
  }
}

void yyerror(const char* msg) { fprintf(stderr, "%s at line %d: '%s'\n", msg, yylineno, yytext); }

void simp_parse(FILE* from) {
  if (from == NULL) {
    fprintf(stderr, "simp_parse: NULL argument\n");
    return;
  }

  yyin = from;
  do {
    yyparse();
  } while (!feof(yyin));
}
