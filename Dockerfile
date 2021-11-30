FROM nix AS skopeo
RUN apk add --update-cache --no-cache \
        make \
        go-md2man
# renovate: datasource=github-releases depName=containers/skopeo
ARG SKOPEO_VERSION=1.5.2
WORKDIR $GOPATH/src/github.com/containers/skopeo
RUN test -n "${SKOPEO_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "${SKOPEO_VERSION}" \
        https://github.com/containers/skopeo.git .
RUN mkdir -p /usr/local/share/man/man1 \
 && nix build -f nix \
 && make docs GOMD2MAN=go-md2man \
 && cp -rfp ./result/bin/skopeo /usr/local/bin/ \
 && mv docs/*.1 /usr/local/share/man/man1

FROM scratch AS local
COPY --from=skopeo /usr/local/bin/skopeo .
COPY --from=skopeo /usr/local/share/man ./share/man/
