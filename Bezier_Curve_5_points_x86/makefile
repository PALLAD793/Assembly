CC = gcc
CFLAGS = -Wall -m64

all: main.o BezierCurve.o
	$(CC) $(CFLAGS) -o output main.o BezierCurve.o `allegro-config --shared`

BezierCurve.o: BezierCurve.s
	nasm -f elf64 -o BezierCurve.o BezierCurve.s

main.o: main.c BezierCurve.h
	$(CC) $(CFLAGS) -c -o main.o main.c

clean:
	rm -f *.o
