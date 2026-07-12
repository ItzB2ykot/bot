FROM golang:1.26-alpine AS builder

ENV CGO_ENABLED=1
ENV GOOS=linux

WORKDIR /build

RUN apk add --no-cache make git build-base

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN --mount=type=cache,id=s/20773efb-d153-48d9-a8f3-664c063af8ac-/root/.cache/go-build,target=/root/.cache/go-build \
    go build -o ongaku ./cmd/music

FROM alpine

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /build/ongaku /app/ongaku
COPY --from=builder /build/configs /app/configs

EXPOSE 8080

ENTRYPOINT ["./ongaku"]
