# ---------------------------------------------
# Overleaf TexLive 2022 (ayaka-notes/overleaf)
# ---------------------------------------------

# Use base image, see texlive/base
# -----------------------------------
# tlnet snapshot cache (flat data image), mounted during the TeX Live install
FROM ghcr.io/ayaka-notes/tlnet-cache:2022 AS tlnet

FROM ghcr.io/ayaka-notes/texlive-full:base-22.04

# LABEL
# -----------------------------------
LABEL \
    org.opencontainers.image.title="Docker Image of TeXLive" \
    org.opencontainers.image.authors="ayaka-notes <public@ayaka.space>" \
    org.opencontainers.image.source="https://github.com/ayaka-notes/texlive-full" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.description="Overleaf TeXLive Image by ayaka-notes"


# ARCH For TEXLIVE
# -----------------------------------
ARG TEXLIVE_BIN_ARCH=x86_64-linux


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
ARG TEXLIVE_Version=2022

# Install texlive like Overleaf
# -----------------------------------
RUN --mount=type=bind,from=tlnet,source=/tlnet,target=/tlnet \
    --mount=type=bind,source=update.sh,target=/tmp/update.sh \
    mkdir /install-tl-unx \
&&  wget --quiet https://tug.org/texlive/files/texlive.asc \
&&  gpg --import texlive.asc \
&&  rm texlive.asc \
&&  gpg --verify /tlnet/install-tl-unx.tar.gz.sha512.asc /tlnet/install-tl-unx.tar.gz.sha512 \
&&  ( cd /tlnet && sha512sum -c install-tl-unx.tar.gz.sha512 ) \
&&  tar -xz -C /install-tl-unx --strip-components=1 -f /tlnet/install-tl-unx.tar.gz \
&&  echo "tlpdbopt_autobackup 0" >> /install-tl-unx/texlive.profile \
&&  echo "tlpdbopt_install_docfiles 0" >> /install-tl-unx/texlive.profile \
&&  echo "tlpdbopt_install_srcfiles 0" >> /install-tl-unx/texlive.profile \
&&  echo "selected_scheme scheme-full" >> /install-tl-unx/texlive.profile \
    \
&&  /install-tl-unx/install-tl \
      -profile /install-tl-unx/texlive.profile \
      -repository /tlnet \
    \
&&  $(find /usr/local/texlive -name tlmgr) path add \
&&  tlmgr install --repository /tlnet \
      latexmk \
      texcount \
      synctex \
      etoolbox \
      xetex \
&&  tlmgr path add \
&&  sh /tmp/update.sh \
&&  rm -rf /install-tl-unx


# System font configuration for XeTeX and LuaTeX
RUN echo "OSFONTDIR = /usr/share/fonts//" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf
COPY 09-texlive.conf /etc/fonts/conf.d/
RUN fc-cache -fsv \
&&  luaotfload-tool --update


# Config file /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf
# Enable shell-escape and so on
# -----------------------------------
RUN echo "shell_escape = t" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf && \
    echo "openout_any = a" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf && \
    echo "openin_any = a" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf 


# Set PATH ENV
# -----------------------------------
ENV PATH="/usr/local/texlive/${TEXLIVE_Version}/bin/${TEXLIVE_BIN_ARCH}:${PATH}"
