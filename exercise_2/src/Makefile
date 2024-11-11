CC=mpicc
CFLAGS=-O3 -fopenmp -march=znver2 -mtune=znver2
LIBS=

all: mandelbrot

mandelbrot: mandelbrot.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

clean:
	rm -f mandelbrot *.o *.pgm
