#!/usr/bin/env bash
# Build script for the resume. All outputs go to sections/output/.
#
# Produces:
#   sections/output/resume.pdf         — local build. Uses secrets.tex if
#                                         present (full street address),
#                                         otherwise secrets.example.tex (city).
#   sections/output/resume-public.pdf  — public build for the repo / README.
#                                         Forces secrets.example.tex (city only)
#                                         and drops the profile photo.
#   sections/output/resume-no-photo.pdf — private (full address), no photo.
#
# Usage:
#   ./build.sh           # build both local and public
#   ./build.sh local     # only resume.pdf
#   ./build.sh public    # only resume-public.pdf (+ README previews)
#   ./build.sh nophoto   # private resume-no-photo.pdf

set -euo pipefail

cd "$(dirname "$0")"

OUT=sections/output

# Sources live in sections/, but xelatex resolves \input relative to the
# output directory, so point TEXINPUTS at sections/ when building into $OUT.
build() {
  mkdir -p "$OUT"
  TEXINPUTS="sections:${TEXINPUTS:-}" \
    xelatex -interaction=nonstopmode -output-directory="$OUT" "sections/$1.tex" > /dev/null
}

build_local() {
  echo "==> Building local resume.pdf"
  build resume
  echo "    $OUT/resume.pdf"
}

build_public() {
  echo "==> Building public resume-public.pdf"
  build resume-public
  echo "    $OUT/resume-public.pdf"
  echo "==> Generating PNG previews for the README"
  pdftoppm -png -r 150 "$OUT/resume-public.pdf" "$OUT/resume-public-page"
  echo "    $OUT/resume-public-page-1.png"
  echo "    $OUT/resume-public-page-2.png"
}

build_nophoto() {
  echo "==> Building private resume-no-photo.pdf"
  build resume-no-photo
  echo "    $OUT/resume-no-photo.pdf"
}

target="${1:-both}"
case "$target" in
  local)   build_local ;;
  public)  build_public ;;
  nophoto) build_nophoto ;;
  both)    build_local; build_public ;;
  *) echo "usage: $0 [local|public|nophoto|both]" >&2; exit 1 ;;
esac
