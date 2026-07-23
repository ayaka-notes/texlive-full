# ---------------------------------------------
# tlnet snapshot data image (ayaka-notes/texlive-full)
# ---------------------------------------------

# Pure data, single flat layer, no OS, no architecture.
# Mount it during multi-arch texlive builds:
#   RUN --mount=type=bind,from=ghcr.io/ayaka-notes/tlnet-cache:<year>,source=/tlnet,target=/tlnet \
#       install-tl -profile ... -repository /tlnet
# NOTE: use a plain path (/tlnet) for -repository, NOT file:///tlnet --
# install-tl tests the local path literally and a URL prefix breaks it.
FROM scratch
COPY . /tlnet
