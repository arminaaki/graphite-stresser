# Build stage
FROM openjdk:8u212-stretch AS build 
WORKDIR /deps
RUN set -x \
      && apt-get update \
      && apt-get install --no-install-recommends --no-install-suggests -y git \
      && git clone https://github.com/feangulo/graphite-stresser.git . \
      && ./gradlew uberJar \
      && groupadd -g 1000 -r user \
      && useradd -u 1000 -r -g user -d /home/user -s /sbin/nologin -c "Nonroot User" user

# Final stage
FROM openjdk:8u212-stretch
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"


ENV HOST localhost
ENV PORT 2003
ENV NUMHOSTS 1
ENV NUMTIMERS 128
ENV INTERVAL 10
ENV DEBUG true

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group /etc/group
USER user

COPY --from=build /deps/build/libs/deps-0.1.jar /graphite-stresser.jar

CMD exec /usr/local/openjdk-8/bin/java -jar /graphite-stresser.jar ${HOST} ${PORT} ${NUMHOSTS} ${NUMTIMERS} ${INTERVAL} ${DEBUG}


