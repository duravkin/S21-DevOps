program = s21_grep
flags = -Werror -Wextra -Wall -std=c11

rebuild: clean all

all: $(program)

$(program): $(program).c $(program).h
	@gcc $(flags) $(program).c -o $(program) 

style_check:
	clang-format -i -style=Google $(program).*
	cppcheck --enable=all --suppress=missingIncludeSystem $(program).*

clean:
	@rm -rf *.o $(program)