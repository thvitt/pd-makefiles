SLIDE_SOURCES ?= $(wildcard [0-9][0-9]*-*.md)
SLIDE_PDFS = $(SLIDE_SOURCES:.md=.pdf)
SLIDE_TEXS = $(SLIDE_SOURCES:.md=.tex)
SLIDE_CLEAN = $(SLIDE_SOURCES:.md=.__clean__) $(SLIDE_SOURCES:.md=-handout.__clean__)
SLIDE_CLEANALL = $(SLIDE_SOURCES:.md=.__cleanall__) $(SLIDE_SOURCES:.md=-handout.__cleanall__)
HANDOUT_TEXS = $(SLIDE_SOURCES:.md=-handout.tex)
HANDOUT_PDFS = $(SLIDE_SOURCES:.md=-handout.pdf)

SLIDE_PANDOC_ARGS=-t beamer --template default --pdf-engine lualatex
SLIDE_PANDOC_EXTRA_ARGS=--slide-level 2 -V theme=TV2

# HANDOUT_PANDOC_ARGS=-t latex --pdf-engine lualatex
# HANDOUT_PANDOC_EXTRA_ARGS=--template tvd
HANDOUT_PANDOC_ARGS=$(SLIDE_PANDOC_ARGS) --lua-filter=exclude.lua -M exclude=solution -V classoption=handout

#LATEXMK_ARGS=-auxdir=.cache -emulate-aux-dir -f -interaction=nonstopmode -quiet
LATEXMK_ARGS=-f -interaction=nonstopmode -quiet -g 


default : slides


slides :: $(SLIDE_PDFS)              ## Render all slides

titlepngs :: $(SLIDE_PDFS:.pdf=-title.png)   ## For each slideshow, extract a png with the first slide as a title

handouts:: $(HANDOUT_PDFS)            ## For each slideshow, generate a handout

%.tex : %.md
	pandoc $(SLIDE_PANDOC_ARGS) $(SLIDE_PANDOC_EXTRA_ARGS) -o $@ $<

%-handout.tex : %.md
	pandoc $(HANDOUT_PANDOC_ARGS) $(SLIDE_PANDOC_EXTRA_ARGS) -o $@ $<

%.pdf : %.tex
	latexmk -pdf -lualatex -shell-escape $(LATEXMK_ARGS) $*



-include .pd-slides.dep

.pd-slides.dep : $(SLIDE_SOURCES)
	md-images -d .pdf $^ > $@


.PHONY: slides-clean clean slides handouts titlepngs default texs

# .PRECIOUS: $(SLIDE_TEXS)

texs : $(SLIDE_TEXS)


slides-clean : $(SLIDE_CLEAN) ## remove generated files for each slideshow
	-rm .pd-slides.dep

slides-cleanall : $(SLIDE_CLEANALL)
	-rm .pd-slides.dep

clean :: slides-clean ## remove generated files for each slideshow

cleanall :: slides-cleanall

%.__clean__ : %.tex
	-latexmk -c $*

%.__cleanall__: %.tex
	-latexmk -C $*
	-rm $^

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
