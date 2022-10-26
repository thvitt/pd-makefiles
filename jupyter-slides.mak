NOTEBOOK_SOURCES=$(wildcard *.ipynb)
NOTEBOOKS_OL=$(NOTEBOOK_SOURCES:.ipynb=-ol.ipynb)
ALL_NOTEBOOK_SOURCES=$(NOTEBOOK_SOURCES) $(NOTEBOOKS_OL)
NOTEBOOK_SLIDES=$(ALL_NOTEBOOK_SOURCES:.ipynb=.slides.html)
#NOTEBOOK_PDFS=$(NOTEBOOK_SOURCES:.ipynb=.pdf)
#NOTEBOOK_PDF_SLIDES=$(NOTEBOOK_SOURCES:.ipynb=.slides.pdf)
NOTEBOOK_CLEAN=$(ALL_NOTEBOOK_SOURCES:.ipynb=.__clean__)
NOTEBOOK_DIST=$(addprefix dist/,$(addsuffix .zip,$(basename $(ALL_NOTEBOOK_SOURCES))))

default: slides handouts

.PHONY: default slides handouts pdf-slides clean watch serve dist

## Erzeugt die Folien zu allen Notebooks.
slides :: $(NOTEBOOK_SLIDES)

## Erzeugt PDF_HAndouts zu allen Notebooks.
handouts :: $(NOTEBOOK_PDFS)

## Erzeugt PDF-Folien via Pandoc.
pdf-slides :: $(NOTEBOOK_PDF_SLIDES)

## Packt die Folien mit allen Assets in PDFs.
dist :: $(NOTEBOOK_DIST)

## Räumt erzeugte Daten auf.
clean :: $(NOTEBOOK_CLEAN)
	-rm .jupyter-slides.dep
	-rm index.html

## Erzeugt eine verlinkte Übersicht aller Folien als HTML.
index.html : $(NOTEBOOK_SOURCES)
	ls -v -1 $(NOTEBOOK_SOURCES) \
		| sed -Ee 's/^(.*)\.ipynb/*\ [\1](\1.slides.html)/' \
		| pandoc -t html --metadata "title=$$(basename $$(pwd))" --self-contained -o $@ -

## Erzeugt alle Fplien und bietet sie auf http://localhost:8000/ an. Öffnet eine Browserfenster.
serve :: slides index.html
	( sleep 0.5 && python3 -m webbrowser -t http://localhost:8000/ ) &
	python3 -m http.server 8000 --bind localhost 



%.slides.html : %.ipynb
	jupyter nbconvert --to slides $(NBCONVERT_EXTRA_ARGS) $<

%.html : %.ipynb
	jupyter nbconvert --to html --embed-images $(NBCONVERT_EXTRA_ARGS) $<

%-ol.ipynb : %.ipynb
	nb-filter-cells -i "$^" -o "$@" -t solution

dist/%.zip : %.slides.html
	linked-assets zip $^ $@

%.pdf : %.ipynb
	pandoc -o $@ -t latex --template=tvd -V links-as-notes -V lang=de --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_NB_EXTRA_ARGS) $<

%.slides.pdf : %.ipynb
	pandoc -o $@ -t beamer --template=default -V lang=de -V theme=tv2 --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_PDFSLIDE_EXTRA_ARGS) $<


%.__clean__: %.ipynb
	-rm -f $*.pdf $*.slides.html $*.slides.pdf

ifndef NO_DEPS
-include .jupyter-slides.dep

.jupyter-slides.dep : $(NOTEBOOK_SOURCES)
	md-images -k -d .pdf -d .slides.pdf $^ > $@
endif

gitignore ::
	git ignore -l .jupyter-slides.dep $(NOTEBOOK_SLIDES) $(NOTEBOOK_PDFS) $(NOTEBOOK_PDF_SLIDES) $(.INTERMEDIATES)

include pd/common.mak
