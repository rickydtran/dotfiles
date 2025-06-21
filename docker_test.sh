#!/bin/env bash

# Build the Docker image
docker build -t ubuntu24-dot-files-test .
# Run the container, mounting current dir to /app
docker run -it --rm -v "$(pwd):/home/root/.dotfiles" -e TERM -e COLORTERM ubuntu24-dot-files-test
