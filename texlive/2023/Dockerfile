# ---------------------------------------------
# Overleaf TexLive 2023 (ayaka-notes/overleaf)
# ---------------------------------------------

# Use base image, see texlive/base
# -----------------------------------
FROM ghcr.io/ayaka-notes/texlive-full:base

# LABEL
# -----------------------------------
LABEL \
    org.opencontainers.image.title="Docker Image of TeXLive" \
    org.opencontainers.image.authors="ayaka-notes <public@ayaka.space>" \
    org.opencontainers.image.source="https://github.com/ayaka-notes/texlive-full" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.description="Overleaf TeXLive Image by ayaka-notes"


# Copy LatexMk... file 
# -----------------------------------
COPY LatexMk /usr/local/share/latexmk/LatexMk
COPY patchSynctex.R /usr/local/bin/
COPY run-chktex.sh /usr/local/bin/

# Set file exec mod
# -----------------------------------
RUN chmod +x /usr/local/bin/* && chmod +x /usr/local/share/latexmk/*


# ARG For TEXLIVE
# -----------------------------------
ARG TEXLIVE_Version=2023
ARG TEXLIVE_MIRROR=https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_Version}/tlnet-final


# Install texlive like Overleaf
# -----------------------------------
RUN mkdir /install-tl-unx \
&&  wget --quiet https://tug.org/texlive/files/texlive.asc \
&&  gpg --import texlive.asc \
&&  rm texlive.asc \
&&  wget --quiet ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz \
&&  wget --quiet ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz.sha512 \
&&  wget --quiet ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz.sha512.asc \
&&  gpg --verify install-tl-unx.tar.gz.sha512.asc \
&&  sha512sum -c install-tl-unx.tar.gz.sha512 \
&&  tar -xz -C /install-tl-unx --strip-components=1 -f install-tl-unx.tar.gz \
&&  rm install-tl-unx.tar.gz* \
&&  echo "tlpdbopt_autobackup 0" >> /install-tl-unx/texlive.profile \
&&  echo "tlpdbopt_install_docfiles 0" >> /install-tl-unx/texlive.profile \
&&  echo "tlpdbopt_install_srcfiles 0" >> /install-tl-unx/texlive.profile \
&&  echo "selected_scheme scheme-full" >> /install-tl-unx/texlive.profile \
    \
&&  /install-tl-unx/install-tl \
      -profile /install-tl-unx/texlive.profile \
      -repository ${TEXLIVE_MIRROR} \
    \
&&  $(find /usr/local/texlive -name tlmgr) path add \
&&  tlmgr install --repository ${TEXLIVE_MIRROR} \
      latexmk \
      texcount \
      synctex \
      etoolbox \
      xetex \
&&  tlmgr path add \
&&  rm -rf /install-tl-unx


# System font configuration for XeTeX and LuaTeX
RUN echo "OSFONTDIR = /usr/share/fonts//" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf
COPY 09-texlive.conf /etc/fonts/conf.d/
RUN fc-cache -fsv


# Config file /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf
# Enable shell-escape and so on
# -----------------------------------
RUN echo "shell_escape = t" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf && \
    echo "openout_any = a" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf && \
    echo "openin_any = a" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf 


# Set PATH ENV
# -----------------------------------
ENV PATH="/usr/local/texlive/${TEXLIVE_Version}/bin/x86_64-linux:${PATH}"
