# makfile configuration
NAME            = tarot
OBJECTS         = tarot.o

# Choose GCC toolchain prefix ('msp430' for MSPGCC / 'msp430-elf' for GCC RedHat/TI)
MSPGCC_PFX      = msp430

# Select flags depending on selected toolchain
CFLAGS          = -D PFX_MSP430  -std=c99   -O1 -Wall -g -mcpu=430    -mmpy=none    -mivcnt=16

# Toolchain executables
CC              = ${MSPGCC_PFX}-gcc
OBJCOPY		= ${MSPGCC_PFX}-objcopy
OBJDUMP         = ${MSPGCC_PFX}-objdump
OBJSIZE         = ${MSPGCC_PFX}-size

.PHONY: all FORCE clean download download-jtag download-bsl dist

#all should be the first target. it's built when make is runwithout args
#all: srom_libc.a ${NAME}.o ${NAME}.elf ${NAME}.a43 ${NAME}.lst ${NAME}.size
all: ${NAME}.o ${NAME}.elf ${NAME}.a43 ${NAME}.lst ${NAME}.size

#additional rules for files
${NAME}.elf: ${OBJECTS}
	${CC} ${CFLAGS} -T pmem.def -o $@ ${OBJECTS}

${NAME}.a43: ${NAME}.elf
	${OBJCOPY} -O ihex $^ $@

${NAME}.lst: ${NAME}.elf
	${OBJDUMP} -dSt $^ >$@

${NAME}.size: ${NAME}.elf
	${OBJSIZE}  $^ >$@

${NAME}.o: main.c
	${CC} ${CFLAGS} -c -o $@ main.c

lib.a: TCB.c
	${CC} ${CFLAGS} -c -o $@ TCB.c



clean:
	rm -f ${NAME} ${NAME}.a43 ${NAME}.lst ${NAME}.elf ${NAME}.size *.o pmem.def

#project dependencies

