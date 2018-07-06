FROM debian:stretch-slim 

ENV BUILD_DIR=/usr/src/target/release/

# Supressing warnings when installing via apt headless
ARG DEBIAN_FRONTEND="noninteractive"

# Needed for building and using the container
ARG BUILD_REQUIREMENTS="ca-certificates gnupg2 curl gcc libc6-dev file"

# Can be removed after building
ARG BUILD_REMOVES="gnupg2 curl file"

# Installing all requirments and using rustup.sh to install rust
RUN \
apt-get update -qq  < /dev/null > /dev/null && \
apt-get install -qq --no-install-recommends --no-install-suggests $BUILD_REQUIREMENTS < /dev/null > /dev/null && \
curl -s https://static.rust-lang.org/rustup.sh | sh -s -- --disable-sudo --channel=nightly; \
apt-get purge -y --auto-remove $BUILD_REMOVES

# Copy the project into the workingdir when building a dependent container
ONBUILD WORKDIR /usr/src
ONBUILD COPY ./src ./src
ONBUILD COPY ./Cargo.* ./

ONBUILD RUN mkdir /app

# Test and build, put the final artifacts in the app directory using the nightly feature from cargo 
ONBUILD RUN cargo test --release
ONBUILD RUN cargo build --release --out-dir /app -Z unstable-options
