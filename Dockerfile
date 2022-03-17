FROM alpine:3.15

RUN apk add --no-cache bash curl jq cargo
RUN cargo install docpars

ADD entrypoint.sh /entrypoint.sh
ADD src /src

ENTRYPOINT ["/entrypoint.sh"]
