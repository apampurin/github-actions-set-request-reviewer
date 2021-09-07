FROM alpine:3.10

RUN apk add curl bash jq
RUN apk add --update coreutils && rm -rf /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
