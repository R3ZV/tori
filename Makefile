CC      := gcc
CFLAGS  := -std=c23 -Wall -Wextra -O2
TARGET  := tori

SRCDIR  := src
BUILDDIR:= build
BINDIR  := bin

CFILES  := $(wildcard $(SRCDIR)/*.c)
CTESTFILES  := $(wildcard tests/*.c)
OBJS    := $(patsubst $(SRCDIR)/%.c,$(BUILDDIR)/%.o,$(CFILES))

run: $(TARGET)
	./$(BINDIR)/$(TARGET) $(ARGS)

test: $(OBJS)
	$(CC) $(CTESTFILES) $(OBJS) -o $(BINDIR)/$@
	./$(BINDIR)/test

$(TARGET): $(OBJS) | $(BINDIR)
	$(CC) cmd/tori/main.c $(OBJS) -o $(BINDIR)/$@

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

clean:
	rm -rf $(BUILDDIR) $(BINDIR)
