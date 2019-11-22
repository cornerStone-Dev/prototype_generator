
/*
 * generating prototypes grammar
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
	//printf("syntax_error\n");
	if (parser_state->begin_attrs==0){
		while( yypParser->yytos>yypParser->yystack ) yy_pop_parser_stack(yypParser);
	}
}

input ::= funclist. {
	//printf("parse done, input exhausted\n");
}

funclist ::= funclist func.
funclist ::= func.

func ::=  type funcname paramlist RPAREN LBLOCK. {
	//printf("type accepted\n");
	parser_state->func_found = 1;
}
func ::=  type funcname paramlist RPAREN beginattrs RATTR LBLOCK. {
	//printf("type accepted\n");
	parser_state->func_found = 1;
}

beginattrs ::= LATTR(A). {
	parser_state->begin_attrs=1;
	parser_state->start_attr=A;
}

funcname ::= IDENT LPAREN.

paramlist ::= paramlist COMMA param.
paramlist ::= param.

param ::= idlist ptr idlist LBRACKET RBRACKET.
param ::= idlist ptr idlist.
param ::= idlist LBRACKET RBRACKET.
param ::= idlist.

// works, eats invalid stuff but oh well compiler will choke anyway
type ::= type STAR.
type ::= type IDENT.
type ::= IDENT(A).                {parser_state->start_func = A;}

idlist ::= idlist IDENT.
idlist ::= IDENT.

ptr ::= ptr STAR.
ptr ::= STAR.

