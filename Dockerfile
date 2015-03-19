FROM ubuntu:14.04
MAINTAINER Michal Raczka me@michaloo.net

# install curl and fluentd deps
RUN apt-get update \
    && apt-get install -y curl libcurl4-openssl-dev ruby ruby-dev make

# install fluentd with plugins
RUN gem install fluentd --no-ri --no-rdoc \
    && fluent-gem install fluent-plugin-elasticsearch \
    fluent-plugin-record-modifier fluent-plugin-exclude-filter \
    fluent-plugin-docker-format fluent-plugin-color-stripper \
    fluent-plugin-parser fluent-plugin-multi-format-parser \
    fluent-plugin-retag \
    && mkdir /etc/fluentd/

# install docker-gen
RUN cd /usr/local/bin \
    && curl -L https://github.com/jwilder/docker-gen/releases/download/0.3.7/docker-gen-linux-amd64-0.3.7.tar.gz \
    | tar -xzv

VOLUME ["/app/config"]

# add startup scripts and config files
ADD ./bin    /app/bin
ADD ./config /app/config


WORKDIR /app

ENV ES_HOST localhost
ENV ES_PORT 9200
ENV LOG_ENV production
ENV DOCKER_HOST unix:///tmp/docker.sock

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/app/bin/start" ]
