#include "s21_cat.h"

int main(int argc, char *argv[]) {
  int file_index = 0;
  Flags flags = {0};
  int flag = parse_flags(argc, argv, &file_index, &flags);
  if (argc < 2 + !!flag) {
    printf("Argument cointer error!\n");
    return 1;
  }
  if (flag >= 0) {
    for (int i = file_index; i < argc; i++) {
      if (!read_file(argv[i], &flags))
        printf("cat: %s: No such file or directory\n", argv[i]);
    }
  } else
    printf("usage: cat [-belnstuv] [file ...]\n");
  return 0;
}

int select_flag(const char symbol, Flags *flags) {
  int flag = 1;
  switch (symbol) {
    case 's':
      flags->s = 1;
      break;
    case 'b':
      flags->b = 1;
      flags->n = 0;
      break;
    case 'n':
      flags->n = !flags->b;
      break;
    case 'e':
      flags->e = 1;
      flags->v = 1;
      break;
    case 'E':
      flags->e = 1;
      break;
    case 'T':
      flags->t = 1;
      break;
    case 't':
      flags->t = 1;
      flags->v = 1;
      break;
    case 'v':
      flags->v = 1;
      break;
    default:
      flag = -1;
      printf("cat: illegal option -- %c\n", symbol);
      break;
  }
  return flag;
}

int parse_flags(int argc, char *argv[], int *i, Flags *flags) {
  int run = 1;
  int flag = 0;
  while (run && ++(*i) < argc) {
    if (argv[*i][0] == '-' && argv[*i][1] != '-') {
      for (int j = 1; j < (int)strlen(argv[*i]); j++)
        flag = select_flag(argv[*i][j], flags);
    } else if (argv[*i][1] == '-') {
      if (!strcmp("--number-nonblank", argv[*i])) {
        flag = 'b';
      } else if (!strcmp("--number", argv[*i])) {
        flag = 'n';
      } else if (!strcmp("--squeeze-blank", argv[*i])) {
        flag = 's';
      } else {
        printf("cat: illegal option -- %c\n", argv[*i][1]);
        flag = -1;
      }
    } else
      run = 0;
  }
  return flag;
}

int print_symbol(Flags *flags, int c, const int prev, int *str_num,
                 int *empty_str) {
  int miss_print = 0;
  if (flags->s) {
    if (prev == '\n' && c == '\n') {
      if (*empty_str) miss_print = 1;
      if (!miss_print) *empty_str = 1;
    } else
      *empty_str = 0;
  }
  if (prev == '\n' && (flags->n || (flags->b && c != '\n'))) {
    printf("%6d\t", (*str_num)++);
  }
  if (flags->e && c == '\n') {
    putchar('$');
  }
  if (flags->t && c == '\t') {
    putchar('^');
    c += 64;
  }
  if (flags->v && c != '\n' && c != '\t') {
    if ((c >= 0 && c <= 31) || c == 127) putchar('^');
    if (c >= 0 && c <= 31) c += 64;
    if (c == 127) c = '?';
  }
  if (!miss_print) putchar(c);
  return 0;
}

int read_file(const char filename[], Flags *flags) {
  int status = 1;
  FILE *fp = fopen(filename, "r");
  if (!fp) {
    status = 0;
  } else {
    int c = EOF, prev = '\n';
    int str_num = 1, empty_str = 0;
    while ((c = fgetc(fp)) != EOF) {
      print_symbol(flags, c, prev, &str_num, &empty_str);
      prev = c;
    }
    fclose(fp);
  }
  return status;
}
