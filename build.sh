#!/usr/bin/env bash
# Build script for the resume.
#
# Produces two PDFs:
#   sections/resume.pdf         — local build. Uses secrets.tex if present
#                                 (full street address), otherwise falls back
#                                 to secrets.example.tex (city only).
#   sections/resume-public.pdf  — public build for the repo / README.
#                                 Forces secrets.example.tex (city only),
#                                 ignoring any local secrets.tex.
#
# Usage:
#   ./build.sh            # build both
#   ./build.sh local      # build only resume.pdf
#   ./build.sh public     # build only resume-public.pdf

set -euo pipefail

cd "$(dirname "$0")"

build_local() {
  echo "==> Building local resume.pdf"
  xelatex -interaction=nonstopmode -output-directory=sections sections/resume.tex > /dev/null
  echo "    sections/resume.pdf"
}

build_public() {
  echo "==> Building public resume-public.pdf"
  xelatex -interaction=nonstopmode -output-directory=sections sections/resume-public.tex > /dev/null
  echo "    sections/resume-public.pdf"
  echo "==> Generating PNG previews for the README"
  pdftoppm -png -r 150 sections/resume-public.pdf sections/resume-public-page
  echo "    sections/resume-public-page-1.png"
  echo "    sections/resume-public-page-2.png"
}

target="${1:-both}"
case "$target" in
  local)  build_local ;;
  public) build_public ;;
  both)   build_local; build_public ;;
  *) echo "usage: $0 [local|public|both]" >&2; exit 1 ;;
esac
