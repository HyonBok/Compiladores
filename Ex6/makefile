# Alvo principal
all: tiny

# Geração do parser (Bison)
tiny.tab.c tiny.tab.h: tiny.y
	bison -d tiny.y

# Geração do scanner (Flex)
lex.yy.c: tiny.l tiny.tab.h
	flex tiny.l

# Compilação final
tiny: lex.yy.c tiny.tab.c tiny.tab.h symbol.c symbol.h
	gcc -o tiny tiny.tab.c lex.yy.c symbol.c -Wall -Wextra -g

# Limpeza dos arquivos gerados
clean:
	rm -f a.out tiny tiny.tab.* lex.yy.c
