FROM golang:1.18-alpine3.14@sha256:70ba8ec1a0e26a828c802c76ecfc65d1efe15f3cc04d579747fd6b0b23e1cea5 AS base
RUN apk add --update-cache --no-cache \
        git \
        make \
        gcc \
        pkgconf \
        musl-dev \
        btrfs-progs \
        btrfs-progs-dev \
        libassuan-dev \
        lvm2-dev \
        device-mapper \
        glib-static \
        libc-dev \
        gpgme-dev \
        protobuf-dev \
        protobuf-c-dev \
        libseccomp-dev \
        libseccomp-static \
        libselinux-dev \
        ostree-dev \
        openssl \
        iptables \
        bash \
        go-md2man

FROM base AS skopeo
# renovate: datasource=github-releases depName=containers/skopeo
ARG SKOPEO_VERSION=1.8.0
WORKDIR $GOPATH/src/github.com/containers/skopeo
RUN test -n "${SKOPEO_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "v${SKOPEO_VERSION}" \
        https://github.com/containers/skopeo.git .
ENV CGO_ENABLED=0
RUN mkdir -p /usr/local/share/man/man1 \
 && make bin/skopeo EXTRA_LDFLAGS="-s -w -extldflags '-static'" BUILDTAGS=containers_image_openpgp GO_DYN_FLAGS= \
 && make docs GOMD2MAN=go-md2man \
 && mv bin/skopeo /usr/local/bin/ \
 && mv docs/*.1 /usr/local/share/man/man1

FROM scratch AS local
COPY --from=skopeo /usr/local/bin/skopeo ./bin/
COPY --from=skopeo /usr/local/share/man ./share/man/
