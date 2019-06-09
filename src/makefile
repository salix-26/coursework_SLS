all: build

build:
	 nasm -f elf64 core.asm -o core.o
	 ld -o core core.o

clean:
	rm *.o
	rm core
