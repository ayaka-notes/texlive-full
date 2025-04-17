# texlive-full
Overleaf's fullest texlive image. Provide you with extreme excellent experience. You can also use this for your personal TeX-Writing, or mount it to your sharelatex container.

> [!WARNING] 
> - This Docker Image **doesn't contain** any sharelatex/overleaf component. It's used for Overleaf/Overleaf Pro's compile.
> - If you want to use Sharelatex CE with inner contained LaTeX compile, refer to [Overleaf official](github.com/overleaf/overleaf) to find more tutorials. This repository is for server-pro's Docker Compile.
> - A long time compile bug [link #1](https://github.com/ayaka-notes/texlive-full/issues/1) has been fixed now(2024.4.17), please update your docker image.
> - TeXLive 2025 is in beta!(2025.4.17).

## TeXLive Version

Thanks to Github Action, we can build all tex image parallel, which includes:
- `ghcr.io/ayaka-notes/texlive-full/texlive:2025.1` (Also `latest` tag)
- `ghcr.io/ayaka-notes/texlive-full/texlive:2024.1`
- `ghcr.io/ayaka-notes/texlive-full/texlive:2023.1`
- `ghcr.io/ayaka-notes/texlive-full/texlive:2022.1`
- `ghcr.io/ayaka-notes/texlive-full/texlive:2021.1`
- `ghcr.io/ayaka-notes/texlive-full/texlive:2020.1`
- `ghcr.io/ayaka-notes/texlive-full/texlive:base`

We use mirror archive from [utah university](https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/), which includes almost all texlive image ranging from 1996 to 2024. And thankes to Overleaf's Dockerfile, we can build this project faster.

> Why texlive 2019 and earlier are not supported ?
>
> To maintain such images is more than difficult. And we believe you may not use it any more since it's too old. If you need, open a issue to let me know.

## Contained Component

The following packages are contained in the docker image.
- fontconfig inkscape pandoc python3-pygments wget python3
- gnupg gnuplot perl-modules perl ca-certificates git
- ghostscript qpdf r-base-core tar

The following fonts are contained in the docker image.
- [Google Fonts](https://fonts.google.com/)
- [Microsoft msttcorefonts](https://packages.ubuntu.com/jammy/ttf-mscorefonts-installer)
- [Overleaf supported fonts](https://www.overleaf.com/learn/latex/Questions/Which_OTF_or_TTF_fonts_are_supported_via_fontspec%3F)


> [!WARNING] 
> Please confirm whether the relevant fonts can be used commercially. We are **not responsible** for any legal issues arising from your incorrect use of fonts. Once you download image, You agree with this automatically.


## License
MIT


## Tech Reminder
While build texlive image(before 2019), you may need to pay attention to the following problems:
- Only `http`/`ftp` is supported before texlive 2017, so you can't use `https` to download, unless you modify the `peal` script.
- Before 2015, only sha256 file is provided. So you can't use sha512 to check.
