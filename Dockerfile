FROM golang:1.14.2-alpine3.11 as builder

ENV GOOS linux
ENV GOARCH amd64

COPY . /workspace
WORKDIR /workspace

RUN apk --no-cache add ca-certificates gcc musl-dev
RUN go build -o /truestreet -trimpath -ldflags "-s -w"

FROM alpine:3.11

RUN apk --no-cache add ca-certificates curl iproute2

WORKDIR /
COPY --from=builder "/truestreet" /truestreet
EXPOSE 1760

ENTRYPOINT [ "/truestreet" ]

