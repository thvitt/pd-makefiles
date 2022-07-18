SLIDE_SOURCES ?= $(wildcard [0-9][0-9]*-*.md)
SLIDE_PDFS = $(SLIDE_SOURCES:.md=.pdf)
SLIDE_CLEAN = $(SLIDE_SOURCES:.md=.__clean__)
HANDOUT_PDFS = $(SLIDE_SOURCES:.md=-handout.pdf)

SLIDE_PANDOC_ARGS=-t beamer --template default --pdf-engine lualatex
SLIDE_PANDOC_EXTRA_ARGS=--slide-level 2 -V theme=TV2

HANDOUT_PANDOC_ARGS=-t latex --pdf-engine lualatex
HANDOUT_PANDOC_EXTRA_ARGS=--template tvd

default : slides


slides :: $(SLIDE_PDFS)              ## Render all slides

titlepngs :: $(SLIDE_PDFS:.pdf=-title.png)   ## For each slideshow, extract a png with the first slide as a title

handouts:: $(HANDOUT_PDFS)            ## For each slideshow, generate a handout

$(SLIDE_PDFS): %.pdf : %.md
	pandoc $(SLIDE_PANDOC_ARGS) $(SLIDE_PANDOC_EXTRA_ARGS) -o $@ $<

$(HANDOUT_PDFS): %-handout.pdf : %.md
	pandoc $(HANDOUT_PANDOC_ARGS) $(HANDOUT_PANDOC_EXTRA_ARGS) -o $@ $<


-include .pd-slides.dep

.pd-slides.dep : $(SLIDE_SOURCES)
	md-images -d .pdf $^ > $@


.PHONY: slides-clean clean


slides-clean : $(SLIDE_CLEAN) ## remove generated files for each slideshow
	-rm .pd-slides.dep

clean :: slides-clean ## remove generated files for each slideshow

%.__clean__ : %.md
	-rm -f $*.pdf $*-handout.pdf $*-title.png

%.pdf : %.svg
	inkscape -o $@ $^


%.pdf : %.dot
	dot -o$@ -Tpdf $(DOT_EXTRA_ARGS) $< 


complete-script.md : $(SLIDE_SOURCES)
	cat $^ > $@


complete-script.pdf : complete-script.md $(SLIDE_PDFS)   ## All handouts concatenated
	pandoc $(HANDOUT_PANDOC_ARGS) $(HANDOUT_PANDOC_EXTRA_ARGS) -o $@ $<



info::  ## some information about the makefile about the makefile
	@echo "## slides.mak: Create pandoc slides"
	@echo "Variables:"
	@echo "  SLIDE_SOURCES=$(SLIDE_SOURCES)"
	@echo "  SLIDE_PDFS=$(SLIDE_PDFS)"
	@echo "  SLIDE_PANDOC_EXTRA_ARGS=$(SLIDE_PANDOC_EXTRA_ARGS)"
	@echo "  .INTERMEDIATES=$(.INTERMEDIATES)"
	@echo "Targets:"
	@echo "  slides   - produces PDF slides"
	@echo "  handouts - produces PDF handouts"
	@echo "  slides-clean - cleanup"



%-title.png : %.pdf   ## Generate a title image suitable for videos
	pdftocairo -png -scale-to-x 1920 -scale-to-y 1080 -singlefile $< `basename $@`

-include pd/common.mak
