#define _GNU_SOURCE

#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

typedef enum {
  FLAG = 1,              /* Flag for flag. */
  PATTERN = 2,           /* Flag for pattern. */
  PATTERNPATH = 3,       /* Flag for pattern filepath. */
  FILEPATH = 5,          /* Flag for filepath. */
  ERROR_FLAG = -1,       /* Flag for error with parsing flags. */
  ERROR_PATTERN = -2,    /* Flag for error with pattern. */
  ERROR_PATTERNPATH = -3 /* Flag for error with filepath pattern */
} ParserFlags;

typedef struct {
  int argc;       /* Number of arguments. */
  char **argv;    /* Arguments. */
  int *arg_types; /* Types of arguments. */
} Parameters;

typedef struct {
  int pattern_without_flag; /* For a standard pattern. */
  int file_counter;         /* Number of files to read. */
  int e;                    /* Pattern. */
  int i;                    /* Ignore uppercase vs. lowercase. */
  int v;                    /* Invert match. */
  int c;                    /* Output count of matching lines only. */
  int l;                    /* Output matching files only. */
  int n;                    /* Precede each matching line with a line number. */
  int h; /* Output matching lines without preceding them by file names.*/
  int s; /* Suppress error messages about nonexistent or unreadable files.*/
  int f; /* Take regexes from a file.*/
  int o; /* Output the matched parts of a matching line.*/
} Flag;

typedef struct {
  char *filepath;  /* Filepath. */
  char *line;      /* Line. */
  size_t line_len; /* Line length. */
  int line_count;  /* Number of lines. */
  int match;       /* Flag for match. */
  int match_count; /* Number of matches. */
} Line_info;

Flag parsed_flags(Parameters *params);
void select_flag(Parameters *params, Flag *flags, char symbol, int i);
int find_pattern_in_flag(char *flag);
void open_file(Parameters *params, Flag *flags);
void applying_flags(Parameters *params, char *filepath, FILE *fp, Flag *flags);
void search_in_line(Parameters *params, Flag *flags, Line_info *line_info);
void read_reg_file(const char *pattern_filepath, Flag *flags,
                   Line_info *line_info);
void regular_search(char *pattern, Flag *flags, Line_info *line_info);
void print_regular_match(Flag *flags, Line_info *line_info, const char *line,
                         regmatch_t *matches);
void print_line(Flag *flags, Line_info *line_info);
void print_filepath(Flag *flags, const char *filepath);
void print_line_number(Flag *flags, const int line_counter);