FROM alpine:3.15@sha256:19b4bcc4f60e99dd5ebdca0cbce22c503bbcff197549d7e19dab4f22254dc864

RUN apk add --no-cache bash curl jq wget
RUN mkdir -p "$HOME/bin" && \
    cd "$HOME/bin" && \
    wget https://github.com/denisidoro/docpars/releases/download/v0.2.0/docpars-v0.2.0-x86_64-unknown-linux-musl.tar.gz && tar xvfz docpars-v0.2.0-x86_64-unknown-linux-musl.tar.gz -C ./ && \
    chmod +x docpars

ADD entrypoint.sh /entrypoint.sh
ADD src /src

ENTRYPOINT ["/entrypoint.sh"]
