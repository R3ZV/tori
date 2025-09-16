CC      := gcc
CFLAGS_WARNINGS := \
    -std=c23 \
    -pedantic \
    -Wall \
    -Wextra \
    -Werror \
    -Wshadow \
    -Wconversion \
    -Wsign-conversion \
    -Wformat=2 \
    -Wnull-dereference \
    -fstack-protector-strong \
    -D_FORTIFY_SOURCE=2 \

CFLAGS_DEBUG := \
    -O2 \
    -g \

CFLAGS_RELEASE := \
    -O2 \
    -DNDEBUG

BUILD ?= debug
ifeq ($(BUILD),release)
    CFLAGS := $(CFLAGS_WARNINGS) $(CFLAGS_RELEASE)
else
    CFLAGS := $(CFLAGS_WARNINGS) $(CFLAGS_DEBUG)
endif

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
