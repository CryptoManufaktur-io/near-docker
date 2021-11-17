FROM debian:bullseye-slim

ARG USER=near
ARG UID=10000
ARG CHAIN=mainnet

ENV NEAR_DEPLOY_URL=https://s3-us-west-1.amazonaws.com/build.nearprotocol.com

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  tzdata \
  bash \
  unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN set -eu \
  && latest_release=$(curl -L ${NEAR_DEPLOY_URL}/nearcore-deploy/${CHAIN}/latest_release) \
  && latest_deploy=$(curl -L ${NEAR_DEPLOY_URL}/nearcore-deploy/${CHAIN}/latest_deploy) \
  && curl -L ${NEAR_DEPLOY_URL}/nearcore/Linux/${latest_release}/${latest_deploy}/neard -o /usr/local/bin/neard \
  && chmod +x /usr/local/bin/neard \
  && neard -V

# See https://stackoverflow.com/a/55757473/12429735RUN
RUN adduser \
    --disabled-password \
    --gecos "" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    "${USER}"

RUN set -eu \
  && mkdir -m 0700 -p /var/lib/near \
  && chown ${USER}:${USER} /var/lib/near

USER ${USER}
WORKDIR /var/lib/near

EXPOSE 3030 23456

ENTRYPOINT ["neard"]
