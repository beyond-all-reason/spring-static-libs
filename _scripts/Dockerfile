ARG UBUNTU_VERSION=please-set
FROM docker.io/ubuntu:${UBUNTU_VERSION}
WORKDIR /build
COPY _scripts /scripts
RUN /scripts/install-linux.sh /build
CMD ["/scripts/make_static_libs.sh", "/build"]
