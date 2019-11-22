/*!re2c re2c:flags:i = 1; */         // re2c block with configuration that turns off #line directives
                                     //
//#include <stdio.h>                   //    C/C++ code


/*!max:re2c*/                        // directive that defines YYMAXFILL (unused)
/*!re2c                              // start of re2c block
    
	mcm = "/*" [^@] ([^*] | ("*" [^/]))* [^@] "*""/";
    scm = "//" [^\n]* "\n";
    wsp = ([ \t\v\n\r] | scm | mcm)+;
	lblock =   "{";
	lparen =   "(";
	rparen =   ")";
	lbracket = "[";
	rbracket = "]";
	lattr =    "/*@";
	rattr =    "@*/";
	comma =    ",";
	star =   "*";
	id = [a-zA-Z_][a-zA-Z_0-9]*;

	
*/                                   // end of re2c block

static int lex(const u8 **YYCURSOR_p, Context * c) // YYCURSOR is defined as a function parameter
{                                    //
    const u8 * YYMARKER;    // YYMARKER is defined as a local variable
	//const u8 * YYCTXMARKER; // YYCTXMARKER is defined as a local variable
	const u8 * YYCURSOR;    // YYCURSOR is defined as a local variable
	const u8 * start;
	start = *YYCURSOR_p;
	YYCURSOR = *YYCURSOR_p;

loop: // label for looping within the lexxer

    /*!re2c                          // start of re2c block
    re2c:define:YYCTYPE = "u8";      //   configuration that defines YYCTYPE
    re2c:yyfill:enable  = 0;         //   configuration that turns off YYFILL
                                     //
    * { *YYCURSOR_p = YYCURSOR; return RBRACKET; }//   default rule with its semantic action
    [\x00] { return 0; }             // EOF rule with null sentinal
    
    wsp {
        start =YYCURSOR;
		goto loop;
    }
	
	lblock {
        // null terminate function prototype or attribute text
        *(c->string_end) = 0;
		*YYCURSOR_p = YYCURSOR;
		return LBLOCK;
    }
	
	lparen { 
		*YYCURSOR_p = YYCURSOR;
		return LPAREN;
    }
    
    rparen {
        c->string_end = (u8 *)YYCURSOR;
		*YYCURSOR_p = YYCURSOR;
		return RPAREN;
    }
	
	lbracket {
		*YYCURSOR_p = YYCURSOR;
		return LBRACKET;
    }
    
    rbracket {
		*YYCURSOR_p = YYCURSOR;
		return RBRACKET;
    }
    
    lattr {
        // null terminate function prototype
        *(c->string_end) = 0;
        // record start of attribute text
        c->string_start = (u8 *)YYCURSOR;
		*YYCURSOR_p = YYCURSOR;
		return LATTR;
    }
    
    rattr {
        // record end of attribute text  
        c->string_end = (u8 *)(YYCURSOR-3);
		*YYCURSOR_p = YYCURSOR;
		return RATTR;
    }
	
	comma {
        // update where we left off  
		*YYCURSOR_p = YYCURSOR;
		return COMMA;
    }
	
	star {

		*YYCURSOR_p = YYCURSOR;
		return STAR;
    }
	
	id {
		// record start of an id
		c->string_start = (u8 *)start;   
		*YYCURSOR_p = YYCURSOR;
		return IDENT;
    }
    */                               // end of re2c block
}  


