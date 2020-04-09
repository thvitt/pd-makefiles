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
	-rm .jupyter-slides.dep
	-rm index.html

index.html : $(NOTEBOOK_SOURCES)
	ls -v -1 $(NOTEBOOK_SOURCES) \
		| sed -Ee 's/^(.*)\.ipynb/*\ [\1](\1.slides.html)/' \
		| pandoc -t html --metadata "title=$$(basename $$(pwd))" --self-contained -o $@ -

serve :: slides index.html
	( sleep 0.5 && python3 -m webbrowser -t http://localhost:8000/ ) &
	python3 -m http.server 8000 --bind localhost 


%.slides.html : %.ipynb
	jupyter nbconvert --to slides $(NBCONVERT_EXTRA_ARGS) $<

%.pdf : %.ipynb
	pandoc -o $@ -t latex --template=tvd -V links-as-notes -V lang=de --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_NB_EXTRA_ARGS) $<

%.slides.pdf : %.ipynb
	pandoc -o $@ -t beamer --template=default -V lang=de -V theme=tv2 --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_PDFSLIDE_EXTRA_ARGS) $<


%.__clean__: %.ipynb
	-rm -f $*.pdf $*.slides.html $*.slides.pdf

-include .jupyter-slides.dep

.jupyter-slides.dep : $(NOTEBOOK_SOURCES)
	md-images -k -d .pdf -d .slides.pdf $^ > $@
