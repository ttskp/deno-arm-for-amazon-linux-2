FROM amazonlinux:2 as dependencies-arm64

ARG PROTOBUF_VERSION=26.0
RUN curl -L -o /protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-aarch_64.zip


FROM amazonlinux:2 as dependencies-amd64

ARG PROTOBUF_VERSION=26.0
RUN curl -L -o /protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip


FROM dependencies-${TARGETARCH}

ARG DENO_VERSION
ARG TARGETARCH

RUN yum -y groupinstall "Development Tools"
RUN yum -y install libglib2.0-dev cmake3
RUN ln -s /usr/bin/cmake3 /usr/bin/cmake

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="${PATH}:/root/.cargo/bin"

# Install Protobuf
RUN unzip protobuf.zip -d /root/.local
ENV PATH="${PATH}:/root/.local/bin:"

RUN git clone --recurse-submodules --depth 1 --branch ${DENO_VERSION} https://github.com/denoland/deno.git

RUN cd deno && RUST_BACKTRACE=full cargo build --verbose --release --locked --bin deno
