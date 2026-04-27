#include <stdio.h>
#include <string.h>

typedef struct {
  int s, b, n, e, t, v;
} Flags;

int parse_flags(int argc, char *argv[], int *i, Flags *flags);
int print_symbol(Flags *flags, int c, const int prev, int *str_num,
                 int *empty_str);
int read_file(const char filename[], Flags *flags);
int select_flag(const char symbol, Flags *flags);