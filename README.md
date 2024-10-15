# The LinsnLED Ethernet protocol documentation

LinsnLED builds hardware to drive large scale LED matrix installations. This project documents the combined RE effort of @tyalie and @mimoja trying to lift the cloak on their proprietary protocol to communicate with their LED matrix receiver modules.

You can see the current state in the nightly release.

## Building

The documentation can be build as html or pdf. It is recommended to use docker to generate the pdf output, as the asciidoctor-mathematical dependency uses Lasem, which struggles with correct font selection. The docker container seems to work correctly.

Build and start the container with
```bash
make run-docker
```

To generate the documents:
```bash
# execute it inside docker for best results
make all  # generate pdf and html
make pdf
make html

# or to build on file change
make watch
```
