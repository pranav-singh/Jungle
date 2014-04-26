all:	lexer

lexer:	lexer.l
	flex lexer.l
	cc -o lexer lex.yy.c -lfl
