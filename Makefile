docs := $(wildcard *.adoc)
pdfs := $(docs:.adoc=.pdf)
htmls := $(docs:.adoc=.html)
options := -r asciidoctor-diagram -a imagesdir=resources/images -r asciidoctor-mathematical -a mathematical-format=svg
options-pdf := -a pdf-themesdir=resources/themes -a pdf-fontsdir=resources/fonts -a pdf-theme=my-theme.yml -a pdf-page-size=A4
all: html pdf
pdf: $(pdfs)
html: $(htmls)

ASCIIDOC = asciidoctor

.PHONY: all pdf html watch

# Call asciidoctor to generate $@ from $^
%.pdf: %.adoc
	$(ASCIIDOC) -r asciidoctor-pdf -b pdf $(options) $(options-pdf) -o build/$@ $^

%.html: %.adoc
	$(ASCIIDOC) $^ $(options) -o build/$@

watch:
	while inotifywait -e modify *.adoc **/*.adoc; do make all; done

run-docker:
	docker build -t my-asciidoctor-image .
	docker run -it -u $(shell id -u):$(shell id -g) -v $(shell pwd):/documents/ my-asciidoctor-image
