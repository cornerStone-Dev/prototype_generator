
/*
STANDARD C
typedef struct BibleStudies {
    const uint8_t * studentName;
    const uint8_t * studyDescription;
    const uint8_t * studyPrayer;
} BibleStudy;

BibleStudy biblestudy1;
biblestudy1.studentName = "John Doe";

************************************************
C$$ Add type interspection
int numMembers = biblestudy1.numMembers;
=
int numMembers = 3;

biblestudy1.Members[0].name;
=
"studentName";




convertToJson(biblestudy1);
{"studentName":"John Doe",...





*/
%include{
#define YYNOERRORRECOVERY 1
}
/* not active when YYNOERRORRECOVERY is defined */
/*%parse_failure {
	printf("parse_failure\n");
	parser_state->error = 1;
}*/

%extra_context {ParserState * parser_state}

%syntax_error {
	printf("syntax_error\n");
	parser_state->status = -1;
	parser_state->num_members=0;
	if (parser_state->begin_attrs==0){
		while( yypParser->yytos>yypParser->yystack ) yy_pop_parser_stack(yypParser);
	}
}

//%left ATSIGN.

input ::= funclist. {printf("parse done, input exhausted\n");}

funclist ::= funclist func.
funclist ::= func.

func ::=  type funcname paramlist RPAREN LBLOCK. {
	printf("type accepted\n");
	//parser_state->status = 1;
	parser_state->func_found = 1;
}
func ::=  type funcname paramlist RPAREN beginattrs RATTR LBLOCK. {
	printf("type accepted\n");
	//parser_state->status = 1;
	parser_state->func_found = 1;
}

beginattrs ::= LATTR(A). {parser_state->begin_attrs=1;printf("beginattrs = %d\n", parser_state->begin_attrs);parser_state->start_attr=A;}

funcname ::= IDENT LPAREN.

paramlist ::= paramlist COMMA param.
paramlist ::= param.

param ::= idlist ptr idlist LBRACKET RBRACKET.
param ::= idlist ptr idlist.
param ::= idlist LBRACKET RBRACKET.
param ::= idlist.

// works, eats invalid stuff but oh well compiler will choke anyway
// *bad* type ::= idlist(A) ptr idlist. {start_func = A;}
type ::= type ATSIGN.        //{start_func = A;}
// *bad* type ::= idlist(A).            //{start_func = A;}
type ::= type IDENT.
type ::= IDENT(A).                {parser_state->start_func = A;}


idlist ::= idlist IDENT.
idlist ::= IDENT.

ptr ::= ptr ATSIGN.
ptr ::= ATSIGN.

// idlist(A) ::= idlist IDENT(B). {A = B;}
//idlist(A) ::= IDENT(X). //{A = X; /*A-overwrites-X*/ } not needed as this is default

/*ptrlist ::= ptrlist ptr.
ptrlist ::= ptr.

ptr ::= ATSIGN.
ptr ::= .*/

//def_open ::= TYPEDEF STRUCT IDENT LBLOCK.
/*def_open ::= struct_def LBLOCK.
struct_def ::= open_type IDENT. 
open_type ::= TYPEDEF STRUCT.*/



