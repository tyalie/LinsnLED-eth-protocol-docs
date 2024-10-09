docs := $(wildcard *.adoc)
pdfs := $(docs:.adoc=.pdf)
htmls := $(docs:.adoc=.html)
options := -r asciidoctor-diagram -a imagesdir=resources/images
options-pdf := -a pdf-themesdir=resources/themes -a pdf-fontsdir=resources/fonts -a pdf-theme=my-theme.yml -a pdf-page-size=A4
all: html pdf
pdf: $(pdfs)
html: $(htmls)

ASCIIDOC = asciidoctor

.PHONY: all pdf html

# Call asciidoctor to generate $@ from $^
%.pdf: %.adoc
	$(ASCIIDOC) -r asciidoctor-pdf -b pdf $(options) $(options-pdf) -o build/$@ $^

%.html: %.adoc
	$(ASCIIDOC) $^ $(options) -o build/$@
