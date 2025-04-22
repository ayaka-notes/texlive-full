# ---------------------------------------------
# Overleaf TexLive Base (ayaka-notes/overleaf)
# ---------------------------------------------

# ---------------------------------------------
# How to pull? 
# $ docker pull ghcr.io/ayaka-notes/texlive-full:base
# How to build?
# $ docker build -t ghcr.io/ayaka-notes/texlive-full:base ./texlive/Base
# ---------------------------------------------

# This Dockerfile is used to build texlive-full:base
# And texlive:2024, texlive:2023 and so on are all based on this
# Base Image Contain fonts, apt-installed component
FROM ubuntu:22.04

# LABEL
# -----------------------------------
LABEL \
    org.opencontainers.image.title="Docker Image of TeXLive" \
    org.opencontainers.image.authors="ayaka-notes <public@ayaka.space>" \
    org.opencontainers.image.source="https://github.com/ayaka-notes/texlive-full" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.description="Overleaf TeXLive Image by ayaka-notes"

# Makes sure LuaTex cache is writable
# -----------------------------------
ENV TEXMFVAR=/tmp/texmf-var

# Set ENV to noninteractive
# -----------------------------------
ENV DEBIAN_FRONTEND noninteractive

# Update to ensure dependencies are updated
# ------------------------------------------
ENV REBUILT_AFTER="2024-14-02"

# Install dependencies
# --------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig inkscape pandoc python3-pygments wget python3 \
    gnupg gnuplot perl-modules perl ca-certificates git ghostscript \
    qpdf r-base-core tar make \
    && rm -rf /var/lib/apt/lists/*


# Install Extra fonts
COPY ./extrafonts /usr/share/fonts/


# Install fonts
# --------------------
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
&& apt-get update && apt-get install -y ttf-mscorefonts-installer \
&& apt update && apt search ^fonts | grep -o '^fonts[^/]*' | xargs apt install -y \
&& wget --quiet https://github.com/google/fonts/archive/main.tar.gz -O gf.tar.gz \
&& rm -rf /var/lib/apt/lists/* \
&& tar -xf gf.tar.gz \
&& mkdir -p /usr/share/fonts/truetype/google-fonts \
&& find $PWD/fonts-main/ -name "*.ttf" -exec install -m644 {} /usr/share/fonts/truetype/google-fonts/ \; || return 1 \
&& rm -f gf.tar.gz \
&& fc-cache -f && rm -rf /var/cache/*
