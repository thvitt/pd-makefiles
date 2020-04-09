NOTEBOOK_SOURCES=$(wildcard *.ipynb)
NOTEBOOK_SLIDES=$(NOTEBOOK_SOURCES:.ipynb=.slides.html)
NOTEBOOK_PDFS=$(NOTEBOOK_SOURCES:.ipynb=.pdf)
NOTEBOOK_PDF_SLIDES=$(NOTEBOOK_SOURCES:.ipynb=.slides.pdf)
NOTEBOOK_CLEAN=$(NOTEBOOK_SOURCES:.ipynb=.__clean__)

default: slides handouts

.PHONY: default slides handouts pdf-slides clean

slides :: $(NOTEBOOK_SLIDES)

handouts :: $(NOTEBOOK_PDFS)

pdf-slides :: $(NOTEBOOK_PDF_SLIDES)

clean :: $(NOTEBOOK_CLEAN)


%.slides.html : %.ipynb
	jupyter nbconvert --to slides $(NBCONVERT_EXTRA_ARGS) $<

%.pdf : %.ipynb
	pandoc -o $@ -t latex --template=tvd -V links-as-notes -V lang=de --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_NB_EXTRA_ARGS) $<

%.slides.pdf : %.ipynb
	pandoc -o $@ -t beamer --template=default -V lang=de -V theme=tv2 --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_PDFSLIDE_EXTRA_ARGS) $<


%.__clean__: %.ipynb
	-rm -f $*.pdf $*.slides.html $*.slides.pdf
