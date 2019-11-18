
all: bin input output tool tool_output protogen bin/protoGenCompiler

bin/protoGenCompiler: proto_gen_compiler.c tool_output/proto_gen_gram.c tool_output/proto_gen_lex.c
	gcc -O2 -s -o bin/protoGenCompiler proto_gen_compiler.c -Wall

tool_output/proto_gen_gram.c: tool/lemon proto_gen_gram.y
	./tool/lemon proto_gen_gram.y -s -dtool_output

tool/lemon: tool/lemon.c tool/lempar.c
	gcc -O2 tool/lemon.c -o tool/lemon

tool/lemon.c:
	curl https://raw.githubusercontent.com/sqlite/sqlite/master/tool/lemon.c > tool/lemon.c

tool/lempar.c:
	curl https://raw.githubusercontent.com/sqlite/sqlite/master/tool/lempar.c > tool/lempar.c

tool_output/proto_gen_lex.c: proto_gen_lex.re
	re2c -W proto_gen_lex.re -o tool_output/proto_gen_lex.c

bin:
	mkdir bin

input:
	mkdir input

output:
	mkdir output

tool:
	mkdir tool

tool_output:
	mkdir tool_output

protogen:
	mkdir protogen

clean:
	rm bin/protoGenCompiler
