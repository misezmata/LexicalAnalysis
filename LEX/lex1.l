%option noyywrap

%{
#include<iostream>
#include<fstream>
#include<stdlib.h>
#include"1805090_SymbolTable.h"
using namespace std;

int line_count=1;
int error_count=0;

ofstream lout;
ofstream tout;

SymbolTable* st;

void onlyToken(string token){
	lout<<"Line no "<<line_count<<": TOKEN <"<<token<<"> Lexeme "<<yytext<<" found\n";
	tout<<"<"<<token<<">";
}
void tokenWithSymbol(string type, string symbol){
	lout<<"Line no "<<line_count<<": TOKEN <"<<type<<", "<<symbol<<"> Lexeme "<<symbol<<" found\n";
	tout<<"<"<<type<<", "<<symbol<<">";
}
void printKeywords(){
	string token;
	int len = strlen(yytext);
	for(int i=0; i<len; i++){
		if(yytext[i] >= 'a' && yytext[i] <= 'z'){
			token += yytext[i] - 'a' + 'A';
		}else token += yytext[i];
	}
	onlyToken(token);
}
void insertIntoScopeTable(string type, string symbol){
	cout<<"type: "<<type<<'\t';
	cout<<"symbol:"<<symbol<<endl;
	st->insert(type, symbol);
	tokenWithSymbol(type, symbol);
}
void const_int_float_char(string type, string symbol){
	cout<<"type: "<<type<<'\t';
	cout<<"symbol:"<<symbol<<endl;
	st->insert(type, symbol);
	tokenWithSymbol(type, symbol);
}
void operatorAndPunc(string type){
	cout<<"type: "<<type<<'\t';
	cout<<yytext<<endl;
	tokenWithSymbol(type, yytext);
}

%}

WHITESPACE [ \t\f\r\v]
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

%%

\n 		{line_count++;}
\r\n 	{line_count++;}
{WHITESPACE}+ {}	

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
	printKeywords();
}

{DIGIT}+ {
    const_int_float_char("CONST_INT", yytext);
}

{DIGIT}*[\.]?{DIGIT}*([Ee](-)?{DIGIT}+)? {
	const_int_float_char("CONST_FLOAT", yytext);
    // cout<<"CONST_FLOAT"<<yytext<<endl;
}

'[^\\]' {
	char c[2] = "x";
	c[0] = yytext[1];
	const_int_float_char("CONST_CHAR", c);
}

'\\[nt\\'afrbv0]' {
	char c[3] = "\\x";
	c[1] = yytext[2];
	// cout<<"detected char: "<<c<<endl;
	const_int_float_char("CONST_CHAR", c);
}

"+" |
"-" {
	operatorAndPunc("ADDOP");
}
"*" |
"/" |
"%" {
	operatorAndPunc("MULOP");
}
"++" |
"--" {
	operatorAndPunc("INCOP");
}
"<" |
"<=" |
">" |
">=" |
"==" |
"!=" {
	operatorAndPunc("RELOP");
}
"=" {
	operatorAndPunc("ASSIGNOP");
}
"&&" |
"||" {
	operatorAndPunc("LOGICOP");
}
"!" {
	operatorAndPunc("NOT");
}
"(" {
	operatorAndPunc("LPAREN");
}
")" {
	operatorAndPunc("RPAREN");
}
"{" {
	operatorAndPunc("LCURL");
	st->enterScope();
}
"}" {
	operatorAndPunc("RCURL");
	st->exitScope();
}
"[" {
	operatorAndPunc("LTHIRD");
}
"]" {
	operatorAndPunc("RTHIRD");
}
"," {
	operatorAndPunc("COMMA");
}
";" {
	operatorAndPunc("SEMICOLON");
}
[A-Za-z_][A-Za-z_0-9]* {
	cout<<"ID: "<<yytext<<endl;
	insertIntoScopeTable("ID", yytext);
}
{DIGIT}*\.{DIGIT}*(\.{DIGIT}*)+ {
	cout<<"Line: "<<line_count<<'\t';
	cout<<"Too many decimal points!"<<endl;
	error_count++;
}
{DIGIT}*(\.)?[Ee]-?{DIGIT}*(\.{DIGIT}*)+ {
	cout<<"Ill formed number in line: "<<line_count<<endl;
	error_count++;
}
{DIGIT}*[\.]?{DIGIT}*([Ee](-)?{DIGIT}+)?

			
<<EOF>> {
	cout<<"end of file"<<endl;
	return 0;
}
. {

}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	st = new SymbolTable(7);
	char ara[100];
	strcpy(ara, argv[1]);
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	// logout= fopen(strcat(argv[1], "_log.txt"),"w");
	// tokenout= fopen(strcat(ara, "_token.txt"),"w");
	lout.open(strcat(argv[1], "_log.txt"));
	tout.open(strcat(ara, "_token.txt"));
	yyin= fin;
	yylex();
	fclose(yyin);
	lout.close();
	tout.close();
	// fclose(tokenout);
	// fclose(logout);
	delete st;
	return 0;
}