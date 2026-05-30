# Minimal Alpine image for building the Awesome-CV resume with XeLaTeX.
#
# Provides:
#   - xelatex + the LaTeX packages the class needs (fontawesome6, tcolorbox,
#     unicode-math, fontspec, ...)
#   - Source Sans 3 and Roboto as clean system OTF fonts, so XeTeX resolves
#     "Source Sans 3 Bold", "Roboto Light Italic", etc. by name
#   - pdftoppm (poppler-utils) for the README PNG previews
#   - make, to drive the build via the Makefile
#
# The texmf tree also ships Type1 (.pfb) copies of Source Sans / Roboto whose
# style names collide with the OTF ones and make XeTeX pick a broken font.
# We reject those Type1 copies via fontconfig so only the clean OTFs win.

FROM alpine:latest

RUN apk add --no-cache \
      make \
      fontconfig \
      poppler-utils \
      font-roboto \
      curl \
      unzip \
      texlive-xetex \
      texmf-dist-most \
      texmf-dist-fontsextra

# Install Source Sans 3 as a clean system font.
RUN curl -fsSL -o /tmp/source-sans.zip \
      https://github.com/adobe-fonts/source-sans/releases/download/3.052R/OTF-source-sans-3.052R.zip \
 && mkdir -p /usr/share/fonts/source-sans-3 \
 && unzip -j /tmp/source-sans.zip 'OTF/*.otf' -d /usr/share/fonts/source-sans-3 \
 && rm /tmp/source-sans.zip

# fontawesome6 is not packaged for Alpine's texmf; install it from CTAN into
# the local texmf tree (macros + bundled OTF icon fonts).
RUN curl -fsSL -o /tmp/fontawesome6.zip https://mirrors.ctan.org/fonts/fontawesome6.zip \
 && unzip -q /tmp/fontawesome6.zip -d /tmp \
 && mkdir -p /usr/share/texmf-local/tex/latex/fontawesome6 \
             /usr/share/texmf-local/fonts/opentype/public/fontawesome6 \
 && cp /tmp/fontawesome6/tex/* /usr/share/texmf-local/tex/latex/fontawesome6/ \
 && cp /tmp/fontawesome6/opentype/*.otf /usr/share/texmf-local/fonts/opentype/public/fontawesome6/ \
 && mktexlsr \
 && rm -rf /tmp/fontawesome6.zip /tmp/fontawesome6

# Reject the colliding Type1 copies of Source Sans / Roboto shipped in texmf,
# then rebuild the font cache.
RUN mkdir -p /etc/fonts/conf.d \
 && printf '%s\n' \
      '<?xml version="1.0"?>' \
      '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">' \
      '<fontconfig>' \
      '  <selectfont><rejectfont>' \
      '    <glob>/usr/local/texlive/*/texmf-dist/fonts/type1/*/sourcesans/*</glob>' \
      '    <glob>/usr/share/texmf-dist/fonts/type1/*/sourcesans/*</glob>' \
      '    <glob>/usr/local/texlive/*/texmf-dist/fonts/type1/*/roboto/*</glob>' \
      '    <glob>/usr/share/texmf-dist/fonts/type1/*/roboto/*</glob>' \
      '  </rejectfont></selectfont>' \
      '</fontconfig>' \
      > /etc/fonts/conf.d/99-reject-texmf-type1.conf \
 && fc-cache -f

WORKDIR /doc
