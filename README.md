# texlive-full
Overleaf's fullest texlive image. Provide you with extreme excellent experience.

> [!WARNING] 
> - This Docker Image **doesn't contain** any sharelatex/overleaf component. It's used for Overleaf/Overleaf Pro's compile.
> - If you want to use Sharelatex CE with inner contained LaTeX compile, refer to [Overleaf official](github.com/overleaf/overleaf) to find more tutorials. This repository is for server-pro's Docker Compile.

You can also use this for your personal TeX-Writing, or mount it to your sharelatex container.

## TeXLive Version

Thanks to Github Action, we can build all tex image parallel, which includes:
- `ghcr.io/ayaka-notes/overleaf/texlive:2023.1` (Also `latest` tag)
- `ghcr.io/ayaka-notes/overleaf/texlive:2022.1`
- `ghcr.io/ayaka-notes/overleaf/texlive:2021.1`
- `ghcr.io/ayaka-notes/overleaf/texlive:2020.1`
- `ghcr.io/ayaka-notes/overleaf/texlive:base`

We use mirror archive from [utah university](https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/), which includes almost all texlive image ranging from 1996 to 2023. And thankes to Overleaf's Dockerfile, we can build this project faster.

> Why texlive 2010 and earlier are not supported ?
>
> To maintain such images is more than difficult. And we believe you may not use it any more since it's too old.

## Contained Component

The following things are contained in the docker image.
- fontconfig inkscape pandoc python3-pygments wget python3
- gnupg gnuplot perl-modules perl ca-certificates git
- ghostscript qpdf r-base-core tar

The following fonts are contained in the docker image.
- [Google Fonts](https://fonts.google.com/)
- [Microsoft msttcorefonts](https://packages.ubuntu.com/jammy/ttf-mscorefonts-installer)
- [Overleaf supported fonts](https://www.overleaf.com/learn/latex/Questions/Which_OTF_or_TTF_fonts_are_supported_via_fontspec%3F)


> [!WARNING] 
> Please confirm whether the relevant fonts can be used commercially. We are not responsible for any legal issues arising from your incorrect use.


## License
MIT


## Tech Reminder
While build texlive image, you may need to pay attention to the following problems:
- Only `http`/`ftp` is supported before texlive 2017, so you can't use `https` to download, unless you modify the `peal` script.
- Before 2015, only sha256 file is provided. So you can't use sha512 to check.
