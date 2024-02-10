_SELF=$(firstword $(MAKEFILE_LIST))
NOTEBOOK_SOURCES=$(filter-out %-ol.ipynb,$(wildcard *.ipynb))
NOTEBOOKS_OL=$(NOTEBOOK_SOURCES:.ipynb=-ol.ipynb)
ALL_NOTEBOOK_SOURCES=$(NOTEBOOK_SOURCES) $(NOTEBOOKS_OL)
NOTEBOOK_SLIDES=$(ALL_NOTEBOOK_SOURCES:.ipynb=.slides.html)
#NOTEBOOK_PDFS=$(NOTEBOOK_SOURCES:.ipynb=.pdf)
#NOTEBOOK_PDF_SLIDES=$(NOTEBOOK_SOURCES:.ipynb=.slides.pdf)
NOTEBOOK_CLEAN=$(ALL_NOTEBOOK_SOURCES:.ipynb=.__clean__)
NOTEBOOK_DIST=$(addprefix dist/,$(addsuffix .zip,$(basename $(ALL_NOTEBOOK_SOURCES))))
NOTEBOOK_REEXEC=$(addprefix .reexec/,$(NOTEBOOK_SOURCES))

export PYDEVD_DISABLE_FILE_VALIDATION=1

default: slides handouts

.PHONY: default slides handouts pdf-slides clean watch serve dist


slides :: $(NOTEBOOK_SLIDES) ## Erzeugt die Folien zu allen Notebooks.

handouts :: $(NOTEBOOK_PDFS) ## Erzeugt PDF_HAndouts zu allen Notebooks.

pdf-slides :: $(NOTEBOOK_PDF_SLIDES) ## Erzeugt PDF-Folien via Pandoc.


dist :: $(NOTEBOOK_DIST)	## Packt die Folien mit allen Assets in PDFs.

clean :: $(NOTEBOOK_CLEAN) ## Räumt erzeugte Daten auf.
	-rm .jupyter-slides.dep
	-rm index.html

index.html : $(NOTEBOOK_SOURCES) ## Erzeugt eine verlinkte Übersicht aller Folien als HTML.
	@htmlindex --output "$@" `ls -v -1 $(NOTEBOOK_SLIDES) | grep -F -v "$@"`
#	ls -v -1 $(NOTEBOOK_SOURCES) \
#		| sed -Ee 's/^(.*)\.ipynb/*\ [\1](\1.slides.html){target="_blank"}/' \
#		| pandoc -t html --metadata "title=$$(basename $$(pwd))" --self-contained -o $@ -

do-serve :: index.html ## Bietet erzeugte Folien auf http://localhost:8000/ an. Öffnet ein Browserfenster.
	( sleep 0.5 && python3 -m webbrowser -t http://localhost:8000/ ) &
	ls $(NOTEBOOK_SOURCES) | entr -r -s "$(MAKE) slides & python3 -m http.server 8000 --bind localhost"

serve :: do-serve ## Erzeugt alle Folien und bietet sie auf http://localhost:8000/ an. Öffnet ein Browserfenster.



%.slides.html : %.ipynb
	jupyter nbconvert --to slides $(NBCONVERT_EXTRA_ARGS) $<

%.html : %.ipynb
	jupyter nbconvert --to html --embed-images $(NBCONVERT_EXTRA_ARGS) $<

%-ol.ipynb : %.ipynb
	nb-filter-cells -i "$^" -o "$@" -t solution

dist/%.zip : %.slides.html %.html %.ipynb %.slides.pdf
	echo "* [Folien]($*.slides.html)\n* [auf einer Seite]($*.html)\n* [Jupyter Notebook]($*.ipynb){download=yes}\n* [PDF-Folien]($*.slides.pdf){download=yes}" \
		| cat - $(dir $(word 2,$(MAKEFILE_LIST)))/jupyter-readme.md \
		| pandoc -t html --standalone -M title="Foliensatz `htmlindex -1 $<`"\
		| linked-assets zip -o $@ --stdin=index.html --ignore-missing $^ 

%.slides.pdf : %.slides.html 
	run-with-server --start-port=9321 -- decktape reveal 'http://localhost:{port}/$<' $@
	# pandoc -o $@ -t beamer --template=default -M lang=de -V theme=tv2 --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_PDFSLIDE_EXTRA_ARGS) $<
#		python3 -m http.server 9321 --bind localhost &\
#		serverpid=$$!; \
#		decktape reveal http://localhost:9321/$< $@; \
#		kill $$serverpid; :

%.pdf : %.ipynb
	pandoc -o $@ -t latex --template=tvd -V links-as-notes -V lang=de --pdf-engine=lualatex --filter=pandoc-svg $(PANDOC_NB_EXTRA_ARGS) $<


%.__clean__: %.ipynb
	-rm -f $*.pdf $*.slides.html $*.slides.pdf

ifndef NO_DEPS
-include .jupyter-slides.dep

.jupyter-slides.dep : $(NOTEBOOK_SOURCES)
	md-images -k -d .pdf -d .slides.pdf $^ > $@
endif

gitignore ::
	git ignore -l .jupyter-slides.dep $(NOTEBOOK_SLIDES) $(NOTEBOOK_PDFS) $(NOTEBOOK_PDF_SLIDES) $(.INTERMEDIATES)

.PHONY: reexec 

reexec : .reexec $(NOTEBOOK_REEXEC)

.reexec :
	mkdir -p .reexec

.reexec/%.ipynb : %.ipynb 
	jupyter nbconvert --to notebook --execute --allow-errors --output="$@-new.ipynb" "$<"
	@mv -v "$<" "$@"
	@mv -v "$@-new.ipynb" "$<"
	@touch "$@"

include pd/common.mak
