#!/usr/bin/env bash
# Build the resume inside a purpose-built Alpine + XeLaTeX image (see
# Dockerfile), so you don't need a local TeX Live install. The image carries
# the exact packages and fonts the class needs (Source Sans 3, Roboto,
# fontawesome6) and pdftoppm for the README previews.
#
# The current directory is mounted at /doc and the build runs as your own
# UID/GID, so generated PDFs/PNGs are owned by you, not root.
#
# Any arguments are passed straight through to build.sh, e.g.:
#   ./docker-build.sh            # build both resume.pdf and resume-public.pdf
#   ./docker-build.sh local      # build only resume.pdf
#   ./docker-build.sh public     # build only resume-public.pdf + previews

set -euo pipefail

cd "$(dirname "$0")"

IMAGE="${IMAGE:-awesome-cv-build}"

# Build the image (cached after the first run).
docker build -t "$IMAGE" -f Dockerfile .

# HOME=/tmp gives fontconfig a writable cache dir when running as --user.
exec docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -i \
  -w "/doc" \
  -v "$PWD":/doc \
  "$IMAGE" \
  ./build.sh "$@"
