BUILDDIR = build
SOURCEDIR = src/bash

SOURCES = $(wildcard $(SOURCEDIR)/*)
OBJECTS = $(patsubst $(SOURCEDIR)/%, $(BUILDDIR)/%, $(SOURCES))

.PHONY: all clean
all: $(OBJECTS)

$(BUILDDIR)/%: $(SOURCEDIR)/%
	@mkdir -p $(BUILDDIR)
	argbash -o $@ $<

clean:
	rm -rf $(BUILDDIR)
