FROM debian:stretch-slim 

ENV BUILD_DIR=/usr/src/target/release/

ARG DEBIAN_FRONTEND="noninteractive"
ARG BUILD_REQUIREMENTS="ca-certificates gnupg2 curl gcc libc6-dev file"
ARG BUILD_REMOVES="ca-certificates gnupg2 curl file"

RUN \
apt-get update -qq  < /dev/null > /dev/null && \
apt-get install -qq --no-install-recommends --no-install-suggests $BUILD_REQUIREMENTS < /dev/null > /dev/null && \
curl -s https://static.rust-lang.org/rustup.sh | sh -s -- --disable-sudo --channel=nightly; \
apt-get purge -y --auto-remove curl ca-certificates 

ONBUILD WORKDIR /usr/src
ONBUILD COPY ./src ./src
ONBUILD COPY ./Cargo.* ./

ONBUILD RUN mkdir /app

ONBUILD RUN cargo test --release
ONBUILD RUN cargo build --release --out-dir /app -Z unstable-options
