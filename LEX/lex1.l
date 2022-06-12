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
	cout<<"type: <"<<type<<">\tname: <"<<name<<">"<<endl;
	if(st->insert(name, type)){
		st->printAll(lout);
	}
}

void printLineNum(){
	cout<<"Current Line: ("<<yytext<<"): "<<yylineno<<'\t';
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
	cout<<"\n\n\n\n\n\n\nMEOMEO"<<endl;
	cout<<"symbol: "<<symbol<<endl;
	cout<<"yytext: "<<string_yytext<<endl;
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
	//cout<<"type: "<<type<<'\t';
	//cout<<"symbol:"<<symbol<<endl;
	tokenWithSymbol(type, symbol);
	insertIntoSymbolTable(symbol, type);
}
void const_char(string type, string charText, char c){
	lout<<"\nLine no "<<yylineno<<": Token <CONST_CHAR> Lexeme "<<charText<<" found --> <CHAR_CONST, "<<c<<">"<<endl;
	tout<<"<"<<type<<", "<<c<<"> ";
	insertIntoSymbolTable(charText, "CHAR_CONST");
}

void operatorAndPunc(string type){
	cout<<"type: "<<type<<'\t';
	cout<<yytext<<endl;
	tokenWithSymbol(type, yytext);
}
char getSpecialChar(string text){
	// cout<<"\ntext to compare: "<<text<<'\t';
	if(!text.compare("'\\n'")) {
		// cout<<"Matched \\n"<<endl;
		return '\n';
	}
	if(!text.compare("'\\t'")){
		// cout<<"Matched \\t"<<endl;
		return '\t';
	} 
	if(!text.compare("'\\\\'")){
		// cout<<"Matched \\\\"<<endl;
		return '\\';
	} 
	if(!text.compare("'\\''")) {
		// cout<<"Matched \\"<<endl;
		return '\'';
	}
	if(!text.compare("'\\a'")) {
		// cout<<"Matched \\a"<<endl;
		return '\a';
	}
	if(!text.compare("'\\f'")) {
		// cout<<"Matched \\f"<<endl;
		return '\f';
	}
	if(!text.compare("'\\r'")) {
		// cout<<"Matched \\r"<<endl;
		return '\r';
	}
	if(!text.compare("'\\b'")) {
		// cout<<"Matched \\b"<<endl;
		return '\b';
	}
	if(!text.compare("'\\v'")) {
		// cout<<"Matched \\v"<<endl;
		return '\v';
	}
	if(!text.compare("'\\0'")) {
		// cout<<"Matched \\0"<<endl;
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
	cout<<"integer"<<endl;
    const_int_float_char("CONST_INT", yytext);
}

{DIGIT}*[\.]?{DIGIT}+([Ee](-)?{DIGIT}+)? {
	cout<<"float"<<endl;
	const_int_float_char("CONST_FLOAT", yytext);
    // cout<<"CONST_FLOAT"<<yytext<<endl;
}

'[^\\]' {
	cout<<"char"<<endl;
	cout<<"Eitay dhortese: "<<yytext<<endl;
	char c[2] = "x";
	c[0] = yytext[1];
	const_char("CONST_CHAR", yytext, c[0]);
}

'\\[nt\\'afrbv0]' {
	cout<<"char \\"<<endl;
	cout<<"na Eitay dhortese: "<<yytext<<endl;
	char c[3] = "\\x";
	c[1] = yytext[2];
	string s = "";
	// cout<<"Found: "<<yytext<<'\t';
	s += getSpecialChar(yytext);
	// cout<<"S: "<<s<<"end"<<endl;
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
	cout<<"ID"<<endl;
	// cout<<"ID: "<<yytext<<endl;
	tokenWithSymbol("ID", yytext);
	insertIntoSymbolTable(yytext, "ID");
}

{DIGIT}*\.{DIGIT}*(\.{DIGIT}*)+ {
	cout<<"too many decimal"<<endl;
	errorAtLine();
	lout<<"Too many decimal points "<<yytext<<endl;
}
{DIGIT}*(\.)?[Ee]-?{DIGIT}*(\.{DIGIT}*)+ {
	cout<<"ill formed"<<endl;
	errorAtLine();
	lout<<"Ill formed number "<<yytext<<endl;
}
{DIGIT}*[\.]?{DIGIT}+([Ee](-)?{DIGIT}+)?[A-Za-z_][A-Za-z_0-9]* {
	cout<<"prefix/ suffix"<<endl;
	errorAtLine();
	lout<<"Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl;
	// cout<<"\tLine No: "<<yylineno<<'\t'<<yytext<<endl;
	// cout<<"\tInvalid Suffix on numeric constant"<<endl;
}
{DIGIT}*[\.][A-Za-z_][A-Za-z_0-9]* {
	cout<<"prefix/ suffix 2"<<endl;
	errorAtLine();
	lout<<"Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl;
}
"''" {
	cout<<"empty \'\'"<<endl;
	errorAtLine();
	lout<<"Empty character constant error ''"<<endl;
}
'\\?..+' {
	cout<<"multi character"<<yytext<<endl<<endl;
	errorAtLine();
	lout<<"Multi character constant error "<<yytext<<endl;
	// cout<<"\nLine: "<<yylineno<<"Multi character constant error"<<endl;
}
'\r?\n {
	cout<<"quote slash n"<<endl;
	errorAtLine(yylineno - 1);
	lout<<"Unterminated character "<<yytext;
}
'.[^'\n]+ {
	cout<<"quote slash chara"<<endl;
	cout<<"EITAY KI ASHE?"<<endl;
	errorAtLine();
	lout<<"Unterminated character "<<yytext<<endl;
}
\" {
	BEGIN STRING;
	string_builder = "";
	printLineNum();
	cout<<"STRING STATE STARTED!"<<endl;
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
	// cout<<"\t\t\t\tEIKHANE: "<<'\t'<<yytext<<endl;
	string_yytext += yytext;
}

<STRING>\r?\n {
	cout<<"eitay to ashar kotha :"<<endl;
	// string_yytext += yytext;
	errorAtLine(startedAt);
	lout<<"Unterminated String "<<string_yytext<<endl;
	cout<<"\t"<<yytext<<endl;
	BEGIN INITIAL;
}
<STRING>\\ {
	// cout<<"ERROR DEO"<<endl;
	// string_yytext += yytext;
	errorAtLine(startedAt);
	lout<<"Unterminated String "<<string_yytext<<endl;
	BEGIN INITIAL;
}
<STRING>\" {
	cout<<"Built String: "<<string_builder<<endl;
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
	cout<<"\t\t\tsingle comment started!"<<endl;
	startedAt = yylineno;
	BEGIN SINGLE_COMMENT;
	string_builder = yytext;
}
<SINGLE_COMMENT>[\\][\r]?[\n] {
	cout<<"\n\n\n\t\t\tEIKHANE: "<<string_builder<<endl;
}
<SINGLE_COMMENT>. {
	cout<<"onnokichu: "<<yytext<<endl;
	string_builder += yytext;
}
<SINGLE_COMMENT>\r?\n {
	cout<<"built comment: "<<string_builder<<endl;
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
	cout<<"built comment: "<<string_builder<<endl;
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
	cout<<"end of file"<<endl;
	return 0;
}
[.] {
	cout<<"eikhane: "<<yytext<<endl;
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