# TODO: update any relevant `bin` scripts to use this builder
# TODO: or, maybe, just switch to using python/whatever
BUILDDIR = root/~/.local/bin
SOURCEDIR = scripts

SOURCES = $(wildcard scripts/*)
OBJECTS = $(patsubst scripts/%, root/~/.local/bin/%, $(SOURCES))

.PHONY: all clean
all: $(OBJECTS)

$(BUILDDIR)/%: $(SOURCEDIR)/%
	argbash -o $@ $<

clean:
	rm $(OBJECTS)
