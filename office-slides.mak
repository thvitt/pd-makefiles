ODP_SOURCES=$(wildcard [0-9]*-*.odp)
PPTX_SOURCES=$(wildcard [0-9]*-*.pptx)
OFFICE_SLIDE_PDFS=$(ODP_SOURCES:.odp=.pdf) $(PPTX_SOURCES:.pptx=.pdf)
OFFICE_SLIDE_CLEAN=$(OFFICE_SLIDE_PDFS:.pdf=.__clean__)


slides :: office-slides

clean :: office-clean


%.pdf : %.odp
	unoconv -f pdf $<


%.pdf : %.pptx
	unoconv -f pdf $<


%.__clean__: %.odp
	-rm -f $*.pdf

%.__clean__: %.pptx
	-rm -f $*.pdf

%.__clean__: %.pdf
	-rm -rf $<


.office-slides.inc :
	echo "office-slides :: $(OFFICE_SLIDE_PDFS)" > $@
	echo "office-clean  :: $(OFFICE_SLIDE_CLEAN)" >> $@

-include .office-slides.inc

info::
	@echo
	@echo "## office-slides.mak"
	@echo "   ODP_SOURCES=$(ODP_SOURCES)"
	@echo "   PPTX_SOURCES=$(PPTX_SOURCES)"
	@echo "   OFFICE_SLIDE_CLEAN=$(OFFICE_SLIDE_CLEAN)"
