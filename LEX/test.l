%option noyywrap

%{
#include<iostream>
#include<fstream>
#include<stdlib.h>
#include"1805090_SymbolTable.h"
using namespace std;

int line_count=1;
SymbolTable *st;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

%%

\n 		{line_count++;}
\r\n 	{line_count++;}
"if" |
"else" |
"for" |
"while" |
"do" |
"break" |
"int" |
"char" |
"float" |
"double" |
"void" |
"return" |
"switch" |
"case" |
"default" |
"continue" {
	printf("Key words!\n");
}

[0-9]+ {
    cout<<"INT "<<yytext<<endl;
}

{DIGIT}*[\.]?{DIGIT}*([Ee](-)?{DIGIT}+)? {
    cout<<"Float "<<yytext<<endl;
}


			
<<EOF>> {
	cout<<"end of file"<<endl;
	return 0;
}
. {
    cout<<"meo "<<yytext<<endl;
}
%%

int main(int argc,char *argv[]){
    st = new SymbolTable(7);
	yylex();
    delete st;
	return 0;
}