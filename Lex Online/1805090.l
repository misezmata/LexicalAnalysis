%option noyywrap yylineno

%x TEMPLATE_STATE

%{
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <set>
using namespace std;

int error_count = 0;
int num = 0;
string builder = "";
set s;
string last_identifier="";
%}

WHITESPACE [ \t\f\r\v]
LETTER [a-zA-Z]
DIGIT [0-9]

%%


{LETTER}+{WHITESPACE}*\< {
    num=1;
    BEGIN TEMPLATE_STATE;
    builder = yytext;
}
<TEMPLATE_STATE>\< {
    num++;
    builder += yytext;
}

<TEMPLATE_STATE>\> {
    num--;
    builder += yytext;
    if(num == 0) {
        cout<<"Template: "<<builder<<" found!"<<endl;
        BEGIN INITIAL;
    }
}
<TEMPLATE_STATE>\r?\n {
    cout<<"ERROR: unfinished template!"<<endl;
    BEGIN INITIAL;
}

<TEMPLATE_STATE>. {
    builder += yytext;
}




exit {
    return 0;
}

%%

int main(int argc, char *argv[]){
    yylineno = 1;
    yylex();
    return 0;
}
