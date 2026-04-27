#include "s21_grep.h"

/* Точка входа. */
int main(int argc, char *argv[]) {
  int *argument_types = (int *)calloc((size_t)argc, sizeof(int));
  if (argument_types == NULL) {
    fprintf(stderr, "Memory allocation error!\n");
  } else {
    Parameters params = {argc, argv, argument_types};
    Flag flags = parsed_flags(&params);
    int has_error = 0, has_filepath = 0;

    for (int i = 1; i < argc; i++) {
      if (argument_types[i] <= 0) has_error = 1;
      if (argument_types[i] == FILEPATH) has_filepath = 1;
    }

    if (argc < 3 || has_error || !has_filepath) {
      fprintf(stderr, "grep: missing pattern and file operand\n");
    } else {
      open_file(&params, &flags);
    }
  }
  free(argument_types);
  return 0;
}

/* Функция для парсинга флагов в структуру и массив. */
Flag parsed_flags(Parameters *params) {
  Flag flags = {0};

  for (int i = 1; i < params->argc; i++)
    for (int j = 1; j < (int)strlen(params->argv[i]); j++)
      if (params->argv[i][0] == '-' &&
          (params->arg_types[i] == 0 || params->arg_types[i] == FLAG))
        select_flag(params, &flags, params->argv[i][j], i);

  /* Повторный парсинг для элементов без флагов. */
  for (int i = 1; i < params->argc; i++) {
    if (params->arg_types[i] == 0) {
      if (params->arg_types[i - 1] >= 0 && !flags.e &&
          !flags.pattern_without_flag && !flags.f) {
        params->arg_types[i] = PATTERN;
        flags.pattern_without_flag++;
      } else if (flags.e || flags.f || flags.pattern_without_flag) {
        params->arg_types[i] = FILEPATH;
        flags.file_counter++;
      }
    }
  }
  return flags;
}

/* Функция для идентификации полученного символа флага. */
void select_flag(Parameters *params, Flag *flags, char symbol, int i) {
  char flags_list[] = {'e', 'i', 'v', 'c', 'l', 'n', 'h', 's', 'f', 'o'};
  int *flags_ptrs[] = {&flags->e, &flags->i, &flags->v, &flags->c, &flags->l,
                       &flags->n, &flags->h, &flags->s, &flags->f, &flags->o};
  int index_found_flag = -1;
  for (int j = 0; index_found_flag < 0 && j < (int)sizeof(flags_list); j++) {
    if (symbol == flags_list[j]) {
      (*flags_ptrs[j])++;
      params->arg_types[i] = FLAG;
      index_found_flag = j;
    }
  }
  if (index_found_flag >= 0 && (symbol == 'e' || symbol == 'f') &&
      params->arg_types[i] == FLAG) {
    if (find_pattern_in_flag(params->argv[i]))
      params->arg_types[i] = symbol == 'e' ? PATTERN : PATTERNPATH;
    else if (i < params->argc - 1)
      params->arg_types[i + 1] = symbol == 'e' ? PATTERN : PATTERNPATH;
    else {
      params->arg_types[i] = symbol == 'e' ? ERROR_PATTERN : ERROR_PATTERNPATH;
      fprintf(stderr, "grep: option requires an argument -- %c\n", symbol);
    }

  } else if (index_found_flag < 0) {
    params->arg_types[i] = ERROR_FLAG;
    fprintf(stderr, "grep: unrecognized option -- %c\n", symbol);
  }
}

/* Функция для поиска паттерна в флаге */
int find_pattern_in_flag(char *flag) {
  int match = 0;
  for (int i = 0; !match && flag[i] != '\0'; i++) {
    if ((flag[i] == 'e' || flag[i] == 'f') && flag[i + 1] != '\0') {
      match = 1;
      int j = 0;
      for (; flag[j + i + 1] != '\0'; j++) flag[j] = flag[j + i + 1];
      flag[j] = '\0';
    }
  }
  return match;
}

/* Функция для открытия файла */
void open_file(Parameters *params, Flag *flags) {
  for (int i = 1; i < params->argc; i++) {
    if (params->arg_types[i] == FILEPATH) {
      char *filepath = params->argv[i];
      FILE *fp = fopen(filepath, "r");
      struct stat statbuf;

      if (!stat(filepath, &statbuf) && S_ISDIR(statbuf.st_mode)) {
        fprintf(stderr, "grep: %s: Is a directory\n", filepath);

      } else if (fp == NULL) {
        if (!flags->s)
          fprintf(stderr, "grep: %s: No such file or directory\n", filepath);

      } else {
        applying_flags(params, filepath, fp, flags);
        fclose(fp);
      }
    } else if (!params->arg_types[i]) {
      fprintf(stderr, "grep: missing file argument\n");
    }
  }
}

/* Функция для применения флагов в переборе строк. */
void applying_flags(Parameters *params, char *filepath, FILE *fp, Flag *flags) {
  Line_info line_info = {filepath, NULL, 0, 0, 0, 0};

  while (getline(&line_info.line, &line_info.line_len, fp) != -1) {
    char *new_line_symbol = strchr(line_info.line, '\n');
    if (new_line_symbol) *new_line_symbol = 0;

    line_info.line_count++;
    line_info.match = 0;

    search_in_line(params, flags, &line_info);

    if (flags->v) line_info.match = !line_info.match;
    if (line_info.match) {
      line_info.match_count++;
      if (!flags->c && !flags->l && (!flags->o || flags->v))
        print_line(flags, &line_info);
    }
  }
  free(line_info.line);
  if (flags->c) {
    if (flags->l) line_info.match_count = !!line_info.match_count;
    print_filepath(flags, filepath);
    printf("%d\n", line_info.match_count);
  }
  if (flags->l && line_info.match_count) {
    printf("%s\n", filepath);
  }
}

/* Функция для поиска паттерна в строке. */
void search_in_line(Parameters *params, Flag *flags, Line_info *line_info) {
  if (flags->f) {
    for (int i = 1; i < params->argc; i++) {
      if (params->arg_types[i] == PATTERNPATH) {
        read_reg_file(params->argv[i], flags, line_info);
      }
    }
  }
  if (flags->e || flags->pattern_without_flag) {
    for (int i = 1; i < params->argc; i++) {
      if (params->arg_types[i] == PATTERN) {
        regular_search(params->argv[i], flags, line_info);
      }
    }
  }
}

/* Функция для открытия файла с регулярным выражением */
void read_reg_file(const char *pattern_filepath, Flag *flags,
                   Line_info *line_info) {
  FILE *fp = fopen(pattern_filepath, "r");
  if (fp == NULL) {
    fprintf(stderr, "grep: %s: No such file or directory\n", pattern_filepath);
  } else {
    char *pattern = NULL;
    size_t pattern_len = 0;

    while (getline(&pattern, &pattern_len, fp) != -1) {
      char *new_line_symbol = strchr(pattern, '\n');
      if (new_line_symbol) *new_line_symbol = 0;

      regular_search(pattern, flags, line_info);
    }
    free(pattern);
    fclose(fp);
  }
}

/* Функция для поиска расширенных регулярных выражений. */
void regular_search(char *pattern, Flag *flags, Line_info *line_info) {
  regex_t regex;
  regmatch_t reg_match;

  if (regcomp(&regex, pattern, REG_EXTENDED | (flags->i ? REG_ICASE : 0))) {
    fprintf(stderr, "grep: invalid regular expression: %s\n", pattern);
  } else {
    char *current_position = line_info->line;

    while (regexec(&regex, current_position, 1, &reg_match, 0) == 0) {
      line_info->match += 1;
      if (!flags->v)
        print_regular_match(flags, line_info, current_position, &reg_match);
      current_position += reg_match.rm_eo;
    }
  }
  regfree(&regex);
}

/* Функция для печати на экран регулярного выражения (флаг -o). */
void print_regular_match(Flag *flags, Line_info *line_info, const char *line,
                         regmatch_t *matches) {
  if (!flags->c && !flags->l && flags->o) {
    print_filepath(flags, line_info->filepath);
    print_line_number(flags, line_info->line_count);
    printf("%.*s\n", (int)(matches->rm_eo - matches->rm_so),
           line + matches->rm_so);
  }
}

/* Функция для печати на экран стандартного потока результата. */
void print_line(Flag *flags, Line_info *line_info) {
  print_filepath(flags, line_info->filepath);
  print_line_number(flags, line_info->line_count);
  printf("%s\n", line_info->line);
}

/* Функция для печати пути файла (с проверкой опций). */
void print_filepath(Flag *flags, const char *filepath) {
  if (flags->file_counter > 1 && !flags->h) printf("%s:", filepath);
}

/* Функция для печати номера строки */
void print_line_number(Flag *flags, const int line_counter) {
  if (flags->n) printf("%d:", line_counter);
}
