all: device asm test

test: test.cc
	hipcc $< -o $@
	./clean.sh

asm: test-kernel.s
	./asm.sh test-kernel -mno-code-object-v3 -mcpu=gfx906

device: test-kernel.cc
	export KMDUMPISA=1
	hipcc $^ -o $@
	mv dump-gfx906.isa test-kernel.mk
	perl parse.pl test-kernel.mk > test-kernel.s
	rm -f device dump-gfx* *.mk *.o
	export KMDUMPISA=0

clean:
	rm -f test *.o *.co *.code *.out *.hsaco *.isa *.isabin *.adipose
