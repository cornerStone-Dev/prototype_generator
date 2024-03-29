
all: bin tool tool_output gen bin/protoGenCompiler

bin/protoGenCompiler: proto_gen_compiler.c tool_output/proto_gen_gram.c tool_output/proto_gen_lex.c
	gcc -O2 -s -o bin/protoGenCompiler proto_gen_compiler.c -Wall

tool_output/proto_gen_gram.c: tool/lemon proto_gen_gram.y
	./tool/lemon proto_gen_gram.y -s -dtool_output
	sed -i 's/void Parse/static void Parse/g' tool_output/proto_gen_gram.c

tool/lemon: tool/lemon.c tool/lempar.c
	gcc -O2 tool/lemon.c -o tool/lemon

tool/lemon.c:
	curl https://raw.githubusercontent.com/sqlite/sqlite/master/tool/lemon.c > tool/lemon.c

tool/lempar.c:
	curl https://raw.githubusercontent.com/sqlite/sqlite/master/tool/lempar.c > tool/lempar.c

tool_output/proto_gen_lex.c: proto_gen_lex.re
	re2c -W --eager-skip proto_gen_lex.re -o tool_output/proto_gen_lex.c

bin:
	mkdir bin

tool:
	mkdir tool

tool_output:
	mkdir tool_output

gen:
	mkdir gen

clean:
	rm -f bin/protoGenCompiler
	rm -f tool_output/proto_gen_gram.c
	rm -f tool_output/proto_gen_lex.c
