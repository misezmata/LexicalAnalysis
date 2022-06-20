%option noyywrap yylineno

%x DEFINE_STATE
%x VALUE_STATE

%{
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <set>
using namespace std;

int error_count = 0;
string id;
string value;

void process(){
    cout<<"MACRO #define "<<id<<" "<<value<<" (MACRO WITH VALUE) DETECTED"<<endl;
}


%}
WHITESPACE [ \t\f\r\v]
LETTER [a-zA-Z]
DIGIT [0-9]
%%


#define{WHITESPACE}+ {
    id = "";
    BEGIN DEFINE_STATE;
}
<DEFINE_STATE>[a-zA-Z][a-zA-Z0-9_]*{WHITESPACE}+ {
    id = yytext;
    value = "";
    BEGIN VALUE_STATE;
}
<DEFINE_STATE>[.]* {
    cout<<"error: define state ended!"<<endl;
    BEGIN INITIAL;
}

<VALUE_STATE>{DIGIT}+ {
	value = yytext;
    process();
    BEGIN INITIAL;
}

<VALUE_STATE>{DIGIT}*[\.]?{DIGIT}+([Ee](-)?{DIGIT}+)? {
	value = yytext;
    process();
    BEGIN INITIAL;
}

<VALUE_STATE>\".*\" {
    value = yytext;
    process();
    BEGIN INITIAL;
}

<VALUE_STATE>[.]* {
    cout<<"ERROR: returing from define->id->"<<endl;
    BEGIN INITIAL;
}

[.]* {

}

%%
int main(int argc, char *argv[]){
    yylineno = 1;
    yylex();
    return 0;
}
