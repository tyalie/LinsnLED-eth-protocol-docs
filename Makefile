BUILD_DIR = build

docs := linsnled-protocol.adoc
chapters := $(wildcard chapters/*.adoc)
pdfs := $(docs:%.adoc=$(BUILD_DIR)/%.pdf)
htmls := $(docs:%.adoc=$(BUILD_DIR)/%.html)
options := -r asciidoctor-diagram -a imagesdir=resources/images \
	   -r ./lib/memory-layout-gen.rb
options-pdf :=  -a imagesoutdir=$(BUILD_DIR)/resources/images-pdf \
	-a bytefield-svg=./bytefield-with-prefix.sh \
	-r asciidoctor-mathematical -a mathematical-format=svg \
	-a pdf-themesdir=resources/themes -a pdf-theme=my-theme.yml \
	-a pdf-fontsdir=resources/fonts \
	-a pdf-page-size=A4
options-html := -a imagesoutdir=$(BUILD_DIR)/resources/images-html
all: html pdf
pdf: $(pdfs)
html: $(htmls)
dependencies := $(chapters) ./chapters/memory-layout.yaml ./lib/memory-layout-gen.rb

ASCIIDOC = asciidoctor

.PHONY: all pdf html watch clean

# Call asciidoctor to generate $@ from $^
$(BUILD_DIR)/%.pdf: %.adoc $(dependencies)
	mkdir -p $(dir $@)
	$(ASCIIDOC) -r asciidoctor-pdf -b pdf $(options) $(options-pdf) -o $@ $< --trace

$(BUILD_DIR)/%.html: %.adoc $(dependencies)
	mkdir -p $(dir $@)
	$(ASCIIDOC) $(options) $(options-html) -o $@ $<

watch:
	while inotifywait -e modify *.adoc **/*.adoc chapters/*; do make all; done

clean:
	rm -rf $(BUILD_DIR)

run-docker:
	docker build -t my-asciidoctor-image .
	docker run -it -u $(shell id -u):$(shell id -g) -v $(shell pwd):/documents/ my-asciidoctor-image
