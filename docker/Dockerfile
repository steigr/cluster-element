FROM alpine
MAINTAINER Mathias Kaufmann <me@stei.gr>
RUN apk add --update ruby tzdata \
 && gem update --system --no-ri --no-rdoc >/dev/null
ADD files /