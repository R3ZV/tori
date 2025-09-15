CC      := gcc
CFLAGS  := -std=c23 -Wall -Wextra -O2
TARGET  := tori

SRCDIR  := src
BUILDDIR:= build

CFILES  := $(wildcard $(SRCDIR)/*.c)
CTESTFILES  := $(wildcard tests/*.c)
OBJS    := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(CFILES))

run: $(TARGET)
	./$(TARGET) $(ARGS)

test: $(OBJS)
	$(CC) $(CTESTFILES) $(OBJS) -o $@
	./test

$(TARGET): $(OBJS)
	$(CC) cmd/tori/main.c $(OBJS) -o $@

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR) $(TARGET) test

.PHONY: tori test
