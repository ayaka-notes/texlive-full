FROM sharelatex/sharelatex:5.0.3


# Makes sure LuaTex cache is writable
# -----------------------------------
ENV TEXMFVAR=/var/lib/overleaf/tmp/texmf-var

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
    qpdf r-base-core tar make


# Install fonts
# --------------------
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
&& apt-get update && apt-get install -y ttf-mscorefonts-installer \
&& apt update && apt search ^fonts | grep -o '^fonts[^/]*' | xargs apt install -y \
&& wget --quiet https://github.com/google/fonts/archive/main.tar.gz -O gf.tar.gz \
&& tar -xf gf.tar.gz \
&& mkdir -p /usr/share/fonts/truetype/google-fonts \
&& find $PWD/fonts-main/ -name "*.ttf" -exec install -m644 {} /usr/share/fonts/truetype/google-fonts/ \; || return 1 \
&& rm -f gf.tar.gz \
&& fc-cache -f && rm -rf /var/cache/*# Makes sure LuaTex cache is writable
# -----------------------------------
ENV TEXMFVAR=/var/lib/overleaf/tmp/texmf-var

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
    qpdf r-base-core tar make


# Install fonts
# --------------------
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
&& apt-get update && apt-get install -y ttf-mscorefonts-installer \
&& apt update && apt search ^fonts | grep -o '^fonts[^/]*' | xargs apt install -y \
&& wget --quiet https://github.com/google/fonts/archive/main.tar.gz -O gf.tar.gz \
&& tar -xf gf.tar.gz \
&& mkdir -p /usr/share/fonts/truetype/google-fonts \
&& find $PWD/fonts-main/ -name "*.ttf" -exec install -m644 {} /usr/share/fonts/truetype/google-fonts/ \; || return 1 \
&& rm -f gf.tar.gz \
&& fc-cache -f && rm -rf /var/cache/*


# Copy LatexMk... file 
# -----------------------------------
COPY LatexMk /usr/local/share/latexmk/LatexMk
COPY patchSynctex.R /usr/local/bin/
COPY run-chktex.sh /usr/local/bin/

# Set file exec mod
# -----------------------------------
RUN chmod 777 -R /usr/local/bin/ && chmod 777 -R /usr/local/share/latexmk/


# ARG For TEXLIVE
# -----------------------------------
ARG TEXLIVE_Version=2024
ARG TEXLIVE_MIRROR=https://mirrors.mit.edu/CTAN/systems/texlive/tlnet/


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


# Config file /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf
# Enable shell-escape and so on
# -----------------------------------
RUN echo "shell_escape = t" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf && \
    echo "openout_any = a" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf && \
    echo "openin_any = a" >> /usr/local/texlive/${TEXLIVE_Version}/texmf.cnf 


# Set PATH ENV
# -----------------------------------
ENV PATH="/usr/local/texlive/${TEXLIVE_Version}/bin/x86_64-linux:${PATH}"
