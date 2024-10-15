docs := $(wildcard *.adoc)
pdfs := $(docs:.adoc=.pdf)
htmls := $(docs:.adoc=.html)
options := -r asciidoctor-diagram -a imagesdir=resources/images
options-pdf := -r asciidoctor-mathematical -a mathematical-format=svg -a pdf-themesdir=resources/themes -a pdf-fontsdir=resources/fonts -a pdf-theme=my-theme.yml -a pdf-page-size=A4
options-html :=
all: html pdf
pdf: $(pdfs)
html: $(htmls)

ASCIIDOC = asciidoctor

.PHONY: all pdf html watch

# Call asciidoctor to generate $@ from $^
%.pdf: %.adoc
	$(ASCIIDOC) -r asciidoctor-pdf -b pdf $(options) $(options-pdf) -o build/$@ $^

%.html: %.adoc
	$(ASCIIDOC) $^ $(options) $(options-html) -o build/$@

watch:
	while inotifywait -e modify *.adoc **/*.adoc; do make all; done

run-docker:
	docker build -t my-asciidoctor-image .
	docker run -it -u $(shell id -u):$(shell id -g) -v $(shell pwd):/documents/ my-asciidoctor-image
