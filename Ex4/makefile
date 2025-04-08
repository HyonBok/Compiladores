a.out: tiny.tab.c lex.yy.c
	gcc tiny.tab.c lex.yy.c -lfl

tiny.tab.c tiny.tab.h: tiny.y
	bison -d tiny.y

lex.yy.c: tiny.l
	flex tiny.l

clean:
	rm -f a.out tiny.tab.* lex.yy.c
