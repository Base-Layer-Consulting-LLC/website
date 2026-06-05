ARG ALPINE_IMG=3.22.4

FROM alpine:${ALPINE_IMG} AS base

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    python3 \
    py3-pip

WORKDIR /repo

COPY scripts/install/ /repo/scripts/install/

RUN chmod +x /repo/scripts/install/*.sh && \
    /repo/scripts/install/curl.sh && \
    /repo/scripts/install/git.sh && \
    /repo/scripts/install/node.sh && \
    /repo/scripts/install/gh.sh && \
    /repo/scripts/install/bump-my-version.sh && \
    /repo/scripts/install/wrangler.sh

ENV PATH="/usr/local/bin:${PATH}"

CMD ["/bin/bash"]
