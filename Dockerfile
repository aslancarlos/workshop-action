FROM alpine:3.23

LABEL org.opencontainers.image.authors="CyberArk Software Ltd."

RUN apk add --no-cache bash curl jq \
	&& mkdir -p /conjur-action \
	&& apk update \
	&& apk upgrade --no-cache zlib

COPY entrypoint.sh /conjur-action/entrypoint.sh

COPY CHANGELOG.md /conjur-action/CHANGELOG.md

RUN chmod +x /conjur-action/entrypoint.sh

WORKDIR /conjur-action

ENTRYPOINT ["/conjur-action/entrypoint.sh"]
