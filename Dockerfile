# Use the official Asciidoctor Docker image as the base
FROM asciidoctor/docker-asciidoctor

# Install bytefield-svg
RUN apk add --no-cache \
    npm \
    && npm install -g bytefield-svg

# Set the working directory
WORKDIR /documents
VOLUME /documents

CMD ["/bin/bash"]
