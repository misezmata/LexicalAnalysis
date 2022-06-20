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
set<string> s;
string last_identifier="";

bool isWhiteSpace(char c){
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
}

void trim_string(string &s){
    string ss = "";
    int len = s.length();
    if(!len) return;
    int startFrom = 0, endAt = len-1;
    while(isWhiteSpace(s[startFrom]) && startFrom < len) startFrom++;
    while(isWhiteSpace(s[endAt]) && endAt >= 0) endAt--;
    for(int i=startFrom; i<=endAt; i++) ss += s[i];
    s = ss;
}


bool processLastIdentifier(){
    trim_string(last_identifier);
    int len = last_identifier.length();
    if(!len) return true;
    for(int i=0; i<len; i++){
        if(isWhiteSpace(last_identifier[i])) {
            cout<<"ERROR: Name cannot be splitted by whitespace!"<<endl;
            return false;
        }
    }
    if(s.find(last_identifier) != s.end()){
        // cout<<"found found!"<<endl;
        cout<<"ERROR: SAME NAME"<<endl;
        return false;
    }
    s.insert(last_identifier);
    // last_identifier = "";
    return true;
}


%}

WHITESPACE [ \t\f\r\v]
LETTER [a-zA-Z]
DIGIT [0-9]

%%


{LETTER}+{WHITESPACE}*\<{WHITESPACE}* {
    num=1;
    s.clear();
    BEGIN TEMPLATE_STATE;
    last_identifier = yytext;
    trim_string(last_identifier);
    last_identifier = last_identifier.substr(0, last_identifier.length() - 1);
    processLastIdentifier();
    builder = last_identifier + "<";
    last_identifier = "";
}
<TEMPLATE_STATE>{WHITESPACE}*\<{WHITESPACE}* {
    num++;
    builder += "<";
    if(!processLastIdentifier()){
        BEGIN INITIAL;
    }
    last_identifier = "";
}

<TEMPLATE_STATE>{WHITESPACE}*\>{WHITESPACE}* {
    num--;
    builder += ">";
    if(!processLastIdentifier()){
        BEGIN INITIAL;
    }
    else{
        last_identifier = "";
        if(num == 0) {
            cout<<"Template: "<<builder<<" found!"<<endl;
            BEGIN INITIAL;
        }
    }
}
<TEMPLATE_STATE>\r?\n {
    cout<<"ERROR: unfinished template!"<<endl;
    BEGIN INITIAL;
}

<TEMPLATE_STATE>. {
    // cout<<yytext<<"."<<endl;
    builder += yytext;
    last_identifier += yytext;
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
