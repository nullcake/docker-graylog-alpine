FROM openjdk:8-jre-alpine

# Build-time metadata as defined at http://label-schema.org
ARG VCS_REF
ARG VERSION

ENV GRAYLOG_URL_BASE https://packages.graylog2.org/releases/graylog
ENV GRAYLOG_DIR /opt/graylog
ENV PATH $GRAYLOG_DIR/bin:$PATH
ENV GRAYLOG_VERSION $VERSION

LABEL \ 
      maintainer="Jochen Schalanda <jochen+docker@schalanda.name>" \
      org.label-schema.name="Graylog Alpine Docker Image" \
      org.label-schema.description="Official Graylog Docker image based on Alpine Linux" \
      org.label-schema.url="https://www.graylog.org/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/joschi/docker-graylog-alpine" \
      org.label-schema.vendor="Graylog, Inc." \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      com.microscaling.docker.dockerfile="/Dockerfile" \
      com.microscaling.license="MIT"

# hadolint ignore=DL3018
RUN set -ex \
  && apk --no-cache add bash su-exec

# hadolint ignore=DL3018
RUN set -ex \
  && apk --no-cache add libcap && setcap 'cap_net_bind_service=+ep' "$JAVA_HOME/bin/java"

RUN set -ex \
  && addgroup -S graylog \
  && adduser -D -S -g '' -G graylog -h "$GRAYLOG_DIR" graylog

WORKDIR $GRAYLOG_DIR
RUN \
  wget -nv "${GRAYLOG_URL_BASE}/graylog-${GRAYLOG_VERSION}.tgz" && \
  wget -nv "${GRAYLOG_URL_BASE}/graylog-${GRAYLOG_VERSION}.tgz.sha256.txt" && \
  sha256sum -c "graylog-${GRAYLOG_VERSION}.tgz.sha256.txt" && \
  tar -xzf "graylog-${GRAYLOG_VERSION}.tgz" --strip-components=1 -C "$GRAYLOG_DIR" && \
  rm -f "graylog-${GRAYLOG_VERSION}.tgz" "graylog-${GRAYLOG_VERSION}.tgz.sha256.txt"

COPY config "$GRAYLOG_DIR/config"
COPY graylog.sh "$GRAYLOG_DIR/bin/graylog"

RUN set -ex \
  && chown -R graylog:graylog "$GRAYLOG_DIR"

COPY docker-entrypoint.sh /

# fix java in alpine
#COPY etc /etc

EXPOSE 9000
USER graylog

VOLUME $GRAYLOG_DIR/data
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["graylog"]
