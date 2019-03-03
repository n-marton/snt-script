FROM golang:1.11-alpine3.8 as CONFD
ARG CONFD_VERSION=v0.16.0
RUN apk update ; apk add git make ; mkdir -p $GOPATH/src/github.com/kelseyhightower
RUN git clone -b ${CONFD_VERSION} https://github.com/kelseyhightower/confd.git $GOPATH/src/github.com/kelseyhightower/confd
RUN cd $GOPATH/src/github.com/kelseyhightower/confd ; make

FROM alpine:3.8
COPY --from=CONFD /go/src/github.com/kelseyhightower/confd/bin/confd  /usr/local/bin/confd
RUN apk update ; apk add curl jq ; chmod +x /usr/local/bin/confd ; mkdir -p /opt/snt/ ; mkdir -p /etc/confd/templates; mkdir -p /etc/confd/conf.d
ADD deploy.sh /opt/snt/
WORKDIR /opt/snt/
CMD [ "./deploy.sh" ]