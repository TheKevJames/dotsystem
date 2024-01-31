BUILDDIR = root/~/.local/bin
SOURCEDIR = scripts

SOURCES = $(wildcard scripts/*)
OBJECTS = $(patsubst scripts/%, root/~/.local/bin/%, $(SOURCES))

.PHONY: all
all: $(OBJECTS)

$(BUILDDIR)/%: $(SOURCEDIR)/%
	argbash -o $@ $<
