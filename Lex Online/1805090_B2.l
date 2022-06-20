%option noyywrap yylineno

%x TEMPLATE_STATE

%{
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <set>
using namespace std;

int error_count = 0;


%}
WHITESPACE [ \t\f\r\v]
LETTER [a-zA-Z]
DIGIT [0-9]
%%


[a-z][A-Za-z0-9]* {
    cout<<"Camel Case: "<<yytext<<endl;
}

[a-z][A-Za-z0-9]*(_[a-zA-Z0-9]+)+ {
    cout<<"Snake Case: "<<yytext<<endl;
}


[.]* {

}

%%
int main(int argc, char *argv[]){
    yylineno = 1;
    yylex();
    return 0;
}
