/* here is the code start */

#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <stdint.h>
#include <dirent.h>

#include "std_types.h"

#define NDEBUG
#define Parse_ENGINEALWAYSONSTACK

typedef struct context_s{
	u8 * string_start;
	u8 * string_end;
} Context;

typedef struct parser_s{
	u8 * start_func;
	u8 * start_attr;
	s32 func_found;
	s32 begin_attrs;
} ParserState;

#include "tool_output/proto_gen_gram.h"
#include "tool_output/proto_gen_lex.c"
#include "tool_output/proto_gen_gram.c"

//#define INTPUT_FILE "input/weeklystat.c"
#define OUTPUT_FILE "protogen/prototypes.h"



int main(int argc, char **argv)
{
	
	const unsigned char * data;
	void *pEngine;                  /* The LEMON-generated LALR(1) parser */
	yyParser sEngine;    /* Space to hold the Lemon-generated Parser object */
	unsigned char output_string[4096] = {0};
	unsigned char * output = output_string;
	Context context = {0};
	/*void *pParser;*/
	int tmp_token;
	ParserState parser_state = {0};
	FILE * pFile, * outputFile;
	size_t lSize;
	unsigned char * buffer;
	size_t result;
	DIR *d;
    struct dirent *dir;
	
	
	outputFile = fopen ( OUTPUT_FILE, "w" );
	if (outputFile==NULL) {fputs ("File error",stderr); exit (1);}
	
	/*pParser = ParseAlloc( malloc, &parser_state );*/
	pEngine = &sEngine;
	ParseInit(pEngine, &parser_state);
	
	// debug
	//~ /* open current directory */
	//~ d = opendir(".");
	//~ if (d==0)
    //~ {
		//~ return -1;
	//~ }
	//~ while ( ((dir = readdir(d)) != NULL) ) {
		//~ printf("%s", dir->d_name);
		//~ printf("  %d\n", (strstr(dir->d_name, ".c")!=0));
		//~ if ( (strstr(dir->d_name, ".c")!=0) ) {
			//~ printf("Passed\n");
		//~ }
	//~ }
	//~ /* close directory */
	//~ closedir(d);
	
	/* open current directory */
	d = opendir(".");
	if (d==0)
    {
		//printf("NO DIR!!!\n");
		return -1;
	}
	
	//printf("about to start\n");
	while ( ((dir = readdir(d)) != NULL) /*&& (strstr(dir->d_name, ".c")!=0)*/ )
	{
		//printf("Got in\n");
		if ( (strstr(dir->d_name, ".c")!=0) ) {
		//printf("%s\n", dir->d_name);
		output = (uint8_t *)stpcpy((char *)output, "/* ");
		output = (uint8_t *)stpcpy((char *)output, dir->d_name);
		output = (uint8_t *)stpcpy((char *)output, " */\n");

		pFile = fopen ( dir->d_name, "rb" );
		if (pFile==NULL) {fputs ("File error",stderr); exit (1);}
		
		
		
		// obtain file size:
		fseek (pFile , 0 , SEEK_END);
		lSize = ftell (pFile);
		rewind (pFile);

		// allocate memory to contain the whole file:
		buffer = (unsigned char*) malloc (sizeof(char)*lSize+1);
		if (buffer == NULL) {fputs ("Memory error",stderr); exit (2);}
		data = buffer;
		/* initialize pointer to valid thing to set to 0 for lexxer */
		context.string_end = output;
		// copy the file into the buffer:
		result = fread (buffer,1,lSize,pFile);
		if (result != lSize) {fputs ("Reading error",stderr); exit (3);}
		
		/* null terminate buffer */
		buffer[lSize]=0;
		
		//ParseTrace(stdout, "debug:: ");

		//printf("starting parse\n");
		do {
			tmp_token = lex(&data, &context);

			Parse(pEngine, tmp_token, context.string_start);
			 
			if (parser_state.func_found == 1) {
				parser_state.func_found = 0;
				output = (uint8_t *)stpcpy((char *)output, (char *)parser_state.start_func);
				//printf("begin_attrs = %d\n", parser_state.begin_attrs);
				if (parser_state.begin_attrs==1) {
					parser_state.begin_attrs = 0;
					output = (uint8_t *)stpcpy((char *)output, " __attribute__((");
					output = (uint8_t *)stpcpy((char *)output, (char *)parser_state.start_attr);
					output = (uint8_t *)stpcpy((char *)output, "))");
				}
				output = (uint8_t *)stpcpy((char *)output, ";\n");
				//printf("function = %s\n", parser_state.start_func);
				fwrite (output_string , sizeof(char), strlen((const char *)output_string), outputFile);
				
				output = output_string;
			}
			
		} while (tmp_token != 0);
		
		

		fclose (pFile);
		/* free memory that stored copy of file */
		free (buffer);
		}
	}
	
	/* close directory */
	closedir(d);
	
	/* flush file out of cache and close both files */
	fflush (outputFile); 
	fclose (outputFile);
	
	/* free parser memory */
	/*ParseFree(pParser, free );*/
	ParseFinalize(pEngine);
	
    return 0;
}
