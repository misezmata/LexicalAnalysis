%option noyywrap yylineno
%x STRING
%x SINGLE_COMMENT
%x MULTI_COMMENT
%{
#include<iostream>
#include<fstream>
#include<stdlib.h>
#include"1805090_SymbolTable.h"
using namespace std;

int error_count=0;

ofstream lout;
ofstream tout;

SymbolTable* st;
string string_builder;
string string_yytext;
int startedAt;


void insertIntoSymbolTable(string name, string type){
	// cout<<"type: <"<<type<<">\tname: <"<<name<<">"<<endl;
	if(st->insert(name, type)){
		st->printAll(lout);
	}
}

void onlyToken(string token){
	lout<<"\nLine no "<<yylineno<<": TOKEN <"<<token<<"> Lexeme "<<yytext<<" found\n";
	tout<<"<"<<token<<"> ";
}
void tokenWithSymbol(string type, string symbol){
	lout<<"\nLine no "<<yylineno<<": TOKEN <"<<type<<"> Lexeme "<<yytext<<" found\n";
	tout<<"<"<<type<<", "<<symbol<<"> ";
}
void handleString(string type, string symbol){
	lout<<"\nLine no "<<startedAt<<": TOKEN <"<<type<<"> Lexeme "<<string_yytext<<" found --> <"<<type<<", \""<<string_builder<<"\">"<<endl;
	tout<<"<"<<type<<", \""<<symbol<<"\"> ";
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

void errorAtLine(int lineNo = yylineno){
	lout<<"\nError at line no "<<lineNo<<": ";
	error_count++;
}

void const_int_float_char(string type, string symbol){
	tokenWithSymbol(type, symbol);
	insertIntoSymbolTable(symbol, type);
}
void const_char(string type, string charText, char c){
	lout<<"\nLine no "<<yylineno<<": Token <CONST_CHAR> Lexeme "<<charText<<" found --> <CHAR_CONST, "<<c<<">"<<endl;
	tout<<"<"<<type<<", "<<c<<"> ";
	insertIntoSymbolTable(charText, "CHAR_CONST");
}

void operatorAndPunc(string type){
	tokenWithSymbol(type, yytext);
}
char getSpecialChar(string text){
	if(!text.compare("'\\n'")) {
		return '\n';
	}
	if(!text.compare("'\\t'")){
		return '\t';
	} 
	if(!text.compare("'\\\\'")){
		return '\\';
	} 
	if(!text.compare("'\\''")) {
		return '\'';
	}
	if(!text.compare("'\\a'")) {
		return '\a';
	}
	if(!text.compare("'\\f'")) {
		return '\f';
	}
	if(!text.compare("'\\r'")) {
		return '\r';
	}
	if(!text.compare("'\\b'")) {
		return '\b';
	}
	if(!text.compare("'\\v'")) {
		return '\v';
	}
	if(!text.compare("'\\0'")) {
		return '\0';
	}
	cout<<"Matched nothing!"<<endl;
	return '\0';
}

%}

WHITESPACE [ \t\f\r\v]
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n

%%

\r?\n 		{}
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

{DIGIT}*[\.]?{DIGIT}+([Ee](-)?{DIGIT}+)? {
	const_int_float_char("CONST_FLOAT", yytext);
}

'[^\\]' {
	char c[2] = "x";
	c[0] = yytext[1];
	const_char("CONST_CHAR", yytext, c[0]);
}

'\\[nt\\'afrbv0]' {
	char c[3] = "\\x";
	c[1] = yytext[2];
	string s = "";
	s += getSpecialChar(yytext);
	const_char("CONST_CHAR", yytext, getSpecialChar(yytext));
}

"+" |
"-" {operatorAndPunc("ADDOP");}
"*" |
"/" |
"%" {operatorAndPunc("MULOP");}
"++" |
"--" {operatorAndPunc("INCOP");}
"<" |
"<=" |
">" |
">=" |
"==" |
"!=" {operatorAndPunc("RELOP");}
"=" {operatorAndPunc("ASSIGNOP");}
"&&" |
"||" {operatorAndPunc("LOGICOP");}
"!" {operatorAndPunc("NOT");}
"(" {operatorAndPunc("LPAREN");}
")" {operatorAndPunc("RPAREN");}
"{" {operatorAndPunc("LCURL");
	st->enterScope();}
"}" {operatorAndPunc("RCURL");
	st->exitScope();}
"[" {operatorAndPunc("LTHIRD");}
"]" {operatorAndPunc("RTHIRD");}
"," {operatorAndPunc("COMMA");}
";" {operatorAndPunc("SEMICOLON");}

[A-Za-z_][A-Za-z_0-9]* {
	tokenWithSymbol("ID", yytext);
	insertIntoSymbolTable(yytext, "ID");
}

{DIGIT}*\.{DIGIT}*(\.{DIGIT}*)+ {
	errorAtLine();
	lout<<"Too many decimal points "<<yytext<<endl;
}
{DIGIT}*(\.)?[Ee]-?{DIGIT}*(\.{DIGIT}*)+ {
	errorAtLine();
	lout<<"Ill formed number "<<yytext<<endl;
}
{DIGIT}*[\.]?{DIGIT}+([Ee](-)?{DIGIT}+)?[A-Za-z_][A-Za-z_0-9]* {
	errorAtLine();
	lout<<"Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl;
}
{DIGIT}*[\.][A-Za-z_][A-Za-z_0-9]* {
	errorAtLine();
	lout<<"Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl;
}
"''" {
	errorAtLine();
	lout<<"Empty character constant error ''"<<endl;
}
'\\?..+' {
	errorAtLine();
	lout<<"Multi character constant error "<<yytext<<endl;
}
'\r?\n {
	errorAtLine(yylineno - 1);
	lout<<"Unterminated character "<<yytext;
}
'.[^'\n]+ {
	errorAtLine();
	lout<<"Unterminated character "<<yytext<<endl;
}
\" {
	BEGIN STRING;
	string_builder = "";
	// printLineNum();
	startedAt = yylineno;
	string_yytext = yytext;
}
<STRING>\\[nt\\'afrbv0] {
	string s = "\'";
	s += yytext;
	s += "\'";
	string_builder += getSpecialChar(s);
	string_yytext += yytext;
}
<STRING>\\\" {
	string_builder += "\"";
	string_yytext += yytext;
}
<STRING>[\\][\r]?[\n] {
	string_yytext += yytext;
}

<STRING>\r?\n {
	errorAtLine(startedAt);
	lout<<"Unterminated String "<<string_yytext<<endl;
	BEGIN INITIAL;
}
<STRING>\\ {
	errorAtLine(startedAt);
	lout<<"Unterminated String "<<string_yytext<<endl;
	BEGIN INITIAL;
}
<STRING>\" {
	string_yytext += yytext;
	handleString("STRING", string_builder);
	BEGIN INITIAL;
}
<STRING>. {
	string_builder += yytext;
	string_yytext += yytext;
}
<STRING><<EOF>> {
	errorAtLine(startedAt);
	lout<<"Unterminated String "<<string_yytext<<endl;
	return 0;
}

"//" {
	startedAt = yylineno;
	BEGIN SINGLE_COMMENT;
	string_builder = yytext;
}
<SINGLE_COMMENT>[\\][\r]?[\n] {
}
<SINGLE_COMMENT>. {
	string_builder += yytext;
}
<SINGLE_COMMENT>\r?\n {
	// cout<<"built comment: "<<string_builder<<endl;
	lout<<"\nLINE no "<<startedAt<<": Token <COMMENT> Lexeme "<<string_builder<<" found"<<endl;
	BEGIN INITIAL;
}

"/*" {
	BEGIN MULTI_COMMENT;
	startedAt = yylineno;
	string_builder = yytext; 
}
<MULTI_COMMENT>"*/" {
	string_builder += yytext;
	// cout<<"built comment: "<<string_builder<<endl;
	lout<<"\nLINE no "<<startedAt<<": Token <COMMENT> Lexeme "<<string_builder<<" found"<<endl;
	BEGIN INITIAL;
}
<MULTI_COMMENT>. {
	string_builder += yytext;
}
<MULTI_COMMENT><<EOF>> {
	errorAtLine(startedAt);
	lout<<"Unterminated String "<<string_yytext<<endl;
	return 0;
}

			
<<EOF>> {
	// cout<<"end of file"<<endl;
	return 0;
}
[.] {
	// cout<<"eikhane: "<<yytext<<endl;
	lout<<"Error at line no "<<yylineno<<": Unrecognized character "<<yytext<<endl<<endl;
	error_count++;
}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
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
	st = new SymbolTable(7);
	yyin= fin;
	yylineno = 1;
	yylex();

	lout<<"Total lines: "<<yylineno<<endl;
	lout<<"Total errors: "<<error_count<<endl;


	fclose(yyin);
	delete st;
	lout.close();
	tout.close();
	// fclose(tokenout);
	// fclose(logout);
	return 0;
}