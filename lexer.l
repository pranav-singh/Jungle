/*  Lexer for Tiger
    Authors:  Pranav Kumar Singh (B11132)
              Saurabh Jain (B11033)
*/

%{
char *c;
int commentDepth = 0;
int StrFlag = 1;
%}

ID      [a-zA-Z][a-zA-Z0-9_]*|"_main"
ASCII [\011\012\013\015\040-\176]{-}[\042\134]

%s COMMENT STRING ESCAPE

%%

 /* Eat up newline */
<INITIAL,COMMENT>\n { continue; }

 /* Eat up whitespace */
<INITIAL>[\t\r\ ]+ { continue; }

 /* Keywords */
<INITIAL>array|if|then|else|while|for|to|do|let|in|end|of|break|nil|function|var|type|import|primitive   { printf("A keyword: %s\n", yytext); continue;}

 /* Object-related keywords */
<INITIAL>class|extends|method|new  { printf("An object-related keyword: %s\n", yytext); continue;}

 /* Symbols */
<INITIAL>
","|":"|";"|"("|")"|"["|"]"|"{"|"}"|"."|":="   { printf("A symbol: %s\n", yytext); }

 /* Operators */
<INITIAL>"+"|"-"|"*"|"/"|"="|"<>"|">"|"<"|">="|"<="|"&"|"|"   printf( "An operator: %s\n", yytext );

 /* Identifiers */
<INITIAL>{ID} { printf("An identifier: %s\n",yytext); }

 /* Integers */ 
<INITIAL>[0-9]+ { printf("An integer: %s\n",yytext); }

 /* Match the starting quote of a string */
<INITIAL>\" { c = yytext; BEGIN STRING; continue; }

 /* Print the string when the closing quote is encountered */
<STRING>\" { if (StrFlag) {
  printf("A string: ");
  if (*c == '"') c++;
  while (c != yytext)
    {
      printf("%c", *c);
      c++;
    }
  printf("\n"); }
  StrFlag = 1;
  BEGIN INITIAL; continue; }

 /* Match printable ascii characters */ 
<STRING>{ASCII}+ { continue; }

 /* Begin matching an escape sequence */ 
<STRING>\\  { BEGIN ESCAPE; continue; }

 /* Illegal string character */
<STRING>. { StrFlag = 0; printf("Error: Illegal string character: %s\n", yytext); BEGIN INITIAL; continue; }

 /* Match all control characters, alphabets, backslash and quote */
<ESCAPE>[abfnrtv]|[\"\\] { BEGIN STRING; continue; }

 /* Match octal and headecimal numbers */
<ESCAPE>([01][0-7]{2})|(2[0-5]{2})|(\170[0-9\101-\106\141-\146]{2}) { printf("Octal or Hex number: %s\n", yytext); BEGIN STRING; continue; }

 /* Illegal escape character */
<ESCAPE>. { StrFlag = 0; printf("Error: Illegal escape character: %s\n", yytext); BEGIN STRING; continue; }

 /* Match the opening of a comment and increase the depth */
<INITIAL,COMMENT>"/*" { BEGIN COMMENT;
                          commentDepth = commentDepth + 1;
                          continue; }
 /* Match the closing of a comment and decrease the depth */
<COMMENT>"*/" { commentDepth = commentDepth - 1;
                  if (!commentDepth) BEGIN INITIAL;
                  continue; }
 /* Eat up the comment */
<COMMENT>. { continue; }

 /* Illegal character */
<INITIAL>. { printf("Error: Illegal character: %s\n", yytext); continue; }

 /* Check for unterminated comments */
<INITIAL,COMMENT><<EOF>> { if (commentDepth != 0) printf("Error: Comment unterminated\n"); yyterminate(); }
%%

int main( int argc, char **argv )
{
  ++argv, --argc;  /* skip over program name */
  if ( argc > 0 )
    yyin = fopen( argv[0], "r" );
  else
    yyin = stdin;

  yylex();
}
