FROM golang:1.26-alpine AS builder

ENV GOOS=linux

WORKDIR /build

RUN apk add --no-cache make git build-base

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ARG GITHASH=docker
ARG BUILD_DATE

RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=1 GOOS=linux go build -o ongaku ./cmd/music

FROM alpine

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /build/ongaku /app/ongaku
COPY --from=builder /build/configs /app/configs

EXPOSE 8080

ENTRYPOINT ["./ongaku"]
