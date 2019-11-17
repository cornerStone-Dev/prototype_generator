
all: bin input output tool tool_output bin/protoGenCompiler

bin/protoGenCompiler: proto_gen_compiler.c tool_output/proto_gen_gram.c tool_output/proto_gen_lex.c sqlite3/sqlite3.o
	gcc -O2 -s -o bin/protoGenCompiler proto_gen_compiler.c sqlite3/sqlite3.o -Wall -ldl

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

sqlite3/sqlite3.o:
	rm -f sqlite-autoconf-3300100.tar.gz
	wget "https://www.sqlite.org/2019/sqlite-autoconf-3300100.tar.gz"
	tar -xvzf sqlite-autoconf-3300100.tar.gz
	rm -f sqlite-autoconf-3300100.tar.gz
	rm -f -R sqlite3
	mv sqlite-autoconf-3300100 sqlite3
	(cd sqlite3 && ./configure)
	sed -i 's/-g -O2/-O2/' sqlite3/Makefile
	sed -i 's/-DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE/-DSQLITE_THREADSAFE=0 -DSQLITE_DQS=0 -DSQLITE_DEFAULT_MEMSTATUS=0 -DSQLITE_LIKE_DOESNT_MATCH_BLOBS -DSQLITE_MAX_EXPR_DEPTH=0 -DSQLITE_OMIT_DECLTYPE -DSQLITE_OMIT_DEPRECATED -DSQLITE_OMIT_PROGRESS_CALLBACK -DSQLITE_OMIT_SHARED_CACHE/g' sqlite3/Makefile
	(cd sqlite3 && make sqlite3.o)

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

clean:
	rm bin/protoGenCompiler
