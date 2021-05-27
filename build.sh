if [ $# == 1 ]; then
	if [ "$1" == "build" ]; then
		node . compile test.bi
		nasm -f elf interpreter.asm -o interpreter.o -w no-zext-reloc
		ld -m elf_i386 interpreter.o -o interpreter.elf
	elif [ "$1" == "clean" ]; then
		rm *.elf *.o code.asm
	elif [ "$1" == "debug" ]; then
		gdb -ex "b _start" -ex "r" -ex "set disassembly-flavor intel" -ex "tui enable" -ex "layout asm" -ex "layout regs" interpreter.elf
	else
		echo "Unknown parameter $1"
	fi
else
	echo "Usage: $0 <build | clean | debug>"
fi