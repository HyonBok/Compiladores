output: a.out
	flex flex.l
	bison -d parser.y
	gcc parser.tab.c lex.yy.c -lfl