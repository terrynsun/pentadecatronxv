# syntax = docker/dockerfile:1.0-experimental
FROM ubuntu:20.04
ARG updated=2023-10-22

RUN apt-get -yq update && apt-get -yq upgrade
RUN apt-get -yq install apt-utils wget less vim xz-utils tar bzip2 git zstd brotli build-essential python3
RUN wget -qO- https://nodejs.org/dist/v18.18.2/node-v18.18.2-linux-x64.tar.xz | tar -x --xz -C /usr/local/ --strip-components=1
RUN npm install -g coffeescript nodemon

RUN useradd -U -M -u 1000 app

COPY --chown=app:app . /app
WORKDIR /app
RUN npm rebuild
USER app

VOLUME ["/secrets"]
ENV SECRETS_PATH=/secrets/secrets.json
ENTRYPOINT ["./main.coffee"]
