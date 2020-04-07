SLIDE_SOURCES=$(wildcard [0-9][0-9]*-*.md)
SLIDE_PDFS=$(SLIDE_SOURCES:.md=.pdf)
SLIDE_CLEAN=$(SLIDE_SOURCES:.md=.__clean__)

HANDOUT_PDFS=$(SLIDE_SOURCES:.md=-handout.pdf)

SLIDE_PANDOC_ARGS=-t beamer --template default --filter pandoc-svg --pdf-engine lualatex
SLIDE_PANDOC_EXTRA_ARGS=--slide-level 2 -V theme=TV2

HANDOUT_PANDOC_ARGS=-t latex --filter pandoc-svg --pdf-engine lualatex
HANDOUT_PANDOC_EXTRA_ARGS=--template tvd

default : slides

slides : $(SLIDE_PDFS)

handouts: $(HANDOUT_PDFS)

$(SLIDE_PDFS): %.pdf : %.md
	pandoc $(SLIDE_PANDOC_ARGS) $(SLIDE_PANDOC_EXTRA_ARGS) -o $@ $<

$(HANDOUT_PDFS): %-handout.pdf : %.md
	pandoc $(HANDOUT_PANDOC_ARGS) $(HANDOUT_PANDOC_EXTRA_ARGS) -o $@ $<


-include .pd-slides.dep

.pd-slides.dep : $(SLIDE_SOURCES)
	md-images -d .pdf $^ > $@


.PHONY: slides-clean clean

slides-clean : $(SLIDE_CLEAN)
	-rm .pd-slides.dep

clean : slides-clean

%.__clean__ : %.md
	-rm -f $*.pdf $*-handout.pdf

%.pdf : %.svg
	inkscape --without-gui --export-file=$@ $^


complete-script.md : $(SLIDE_SOURCES)
	cat $^ > $@


complete-script.pdf : complete-script.md $(SLIDE_PDFS)
	pandoc $(HANDOUT_PANDOC_ARGS) $(HANDOUT_PANDOC_EXTRA_ARGS) -o $@ $<
