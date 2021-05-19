FROM rust:1.52-buster as builder
WORKDIR /usr/src/registry_init
COPY ./reg-tool .
RUN cargo install --path .

FROM debian:buster-slim
COPY --from=builder /usr/local/cargo/bin/reg-tool /usr/local/bin/reg-tool
COPY ./reg-tool/example/sample.txt /images.txt
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
