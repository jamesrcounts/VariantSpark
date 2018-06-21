FROM jamesrcounts/spark:2.3.0 AS base
RUN apk -U add bash
ARG GO_VERSION=1.8.1

# KOPS_GITISH: Modify to build at an explicit tag/gitish
ARG KOPS_GITISH=release

# KUBECTL_SOURCE: Change to kubernetes-dev/ci for CI
ARG KUBECTL_SOURCE=kubernetes-release/release

# KUBECTL_TRACK: Currently latest from KUBECTL_SOURCE. Change to latest-1.3.txt, etc. if desired.
ARG KUBECTL_TRACK=stable.txt

ARG KUBECTL_ARCH=linux/amd64

RUN set -ex && \
        apk add --no-cache --virtual build-dependencies curl jq git bash gcc musl-dev openssl go make && \
        apk add  --no-cache vim ca-certificates &&\
        \
        KUBECTL_VERSION=$(curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_TRACK}") && \
        curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_VERSION}/bin/${KUBECTL_ARCH}/kubectl" > /usr/bin/kubectl && \
        chmod +x /usr/bin/kubectl &&\
        \
        rm -rf /go /usr/local/go && \
        apk del build-dependencies && \
        rm -rf /var/cache/apk/* && \
        \
        echo "=== Fetched kubectl ${KUBECTL_VERSION} ==="

ENV PATH "/opt/spark/bin:${PATH}"
WORKDIR /opt/ml

ENV MASTER http://localhost:8001

COPY ./importance-ch22.sh /opt/ml/importance-ch22.sh
ENTRYPOINT ["/opt/ml/importance-ch22.sh"]