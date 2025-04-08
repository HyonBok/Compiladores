a.out: parser.tab.c lex.yy.c
	gcc parser.tab.c lex.yy.c -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: flex.l
	flex flex.l

clean:
	rm -f a.out parser.tab.* lex.yy.c
