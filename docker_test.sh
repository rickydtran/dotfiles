#!/bin/env bash

# Build the Docker image
docker build --build-arg DISTRO=ubuntu:latest -t dot-files-test .
# Run the container, mounting current dir to /app
docker run -it -e TERM -e COLORTERM --rm dot-files-test
