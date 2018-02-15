FROM openjdk:8-jre-alpine
MAINTAINER CrazyMax <crazy-max@users.noreply.github.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="jetbrains-license-server" \
  org.label-schema.description="JetBrains License Server image based on Alpine Linux" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

RUN apk --update --no-cache add \
    curl supervisor tzdata zip \
  && rm -rf /var/cache/apk/* /tmp/*

ENV JLS_PATH="/opt/jetbrains-license-server" \
  JLS_VERSION="15802" \
  JLS_SHA256="e0030be1fd06e2db19576363a388d8b84e7b33c9d48c54f0cfcdc032ddd96181" \
  USERNAME="docker" \
  UID=1000 GID=1000

ADD entrypoint.sh /entrypoint.sh
ADD assets /

RUN mkdir -p "$JLS_PATH" \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/lsi.zip" \
  && echo "$JLS_SHA256  /tmp/lsi.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/lsi.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/lsi.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && chmod a+x /entrypoint.sh

EXPOSE 80
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
