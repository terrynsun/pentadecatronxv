# syntax = docker/dockerfile:1.0-experimental
FROM node:25
RUN npm install -g coffeescript nodemon

# node user is created by the node image
COPY --chown=node:node . /home/node
WORKDIR /home/node
USER 1000

RUN npm rebuild

VOLUME ["/secrets"]
ENV SECRETS_PATH=/secrets/secrets.json
ENTRYPOINT ["./main.coffee"]
