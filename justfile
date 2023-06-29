# vim: ft=make

alias r := run
alias rf := run_with_file

run:
	pushd src/simp_lang && \
	yacc -t -d parser.y
	xmake build
	./build/linux/x86_64/release/simp_lang-project

run_with_file file:
	pushd src/simp_lang && \
	yacc -t -d parser.y
	xmake build
	./build/linux/x86_64/release/simp_lang-project < {{file}}
