
FROM golang:1.9.2-alpine AS builder

WORKDIR /go/src/app

COPY . .

RUN go install



FROM alpine:3.6

WORKDIR /opt

# required to access GitLab server over HTTPS,
# otherwise fails with error: x509: failed to load system roots and no roots provided
RUN apk add --no-cache ca-certificates

COPY --from=builder /go/bin/app .


ENTRYPOINT ["/opt/app"]
