FROM alpine:3.24

LABEL org.opencontainers.image.authors="CyberArk Software Ltd."

RUN apk add --no-cache bash curl jq \
	&& mkdir -p /conjur-action \
	&& apk update \
	&& apk upgrade --no-cache zlib

COPY entrypoint.sh /conjur-action/entrypoint.sh

COPY CHANGELOG.md /conjur-action/CHANGELOG.md

RUN chown -R 1001:0 /conjur-action \
	&& chmod -R g=u /conjur-action \
	&& chmod ug+x /conjur-action/entrypoint.sh

WORKDIR /conjur-action

USER 1001

ENTRYPOINT ["/conjur-action/entrypoint.sh"]
