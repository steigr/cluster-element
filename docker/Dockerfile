FROM alpine
MAINTAINER Mathias Kaufmann <me@stei.gr>
RUN apk add --update ruby tzdata git docker bash ruby-dev rsync ruby-json openssl ca-certificates \
 && gem update --system --no-ri --no-rdoc >/dev/null \
 && gem install --no-ri --no-rdoc toml-rb pry thor awesome_print httparty activesupport ipaddress macaddr \
 && rm /var/cache/apk/*
ADD files /
RUN /bin/cetk update