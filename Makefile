C = gcc
CFLAGS=-Wunused
CFILES != find . -name '*.c'

all: tori

tori: $(CFILES)
	$(C) $(CFLAGS) $(CFILES) -o tori

clean:
	rm tori

.PHONY: all tori clean
