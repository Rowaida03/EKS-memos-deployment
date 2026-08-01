FROM node:22-alpine AS frontend-build
RUN apk add --no-cache libc6-compat


RUN corepack enable


WORKDIR /eks-memos/memos

COPY memos/web/package.json memos/web/pnpm-lock.yaml ./web/

RUN cd web && pnpm install --frozen-lockfile

COPY memos/ ./

RUN cd web && pnpm run release



FROM golang:1.26-alpine3.22 AS backend-build

RUN apk add --no-cache git ca-certificates

WORKDIR /eks-memos/memos


COPY memos/go.mod memos/go.sum ./
RUN go mod download


COPY memos/ ./

COPY --from=frontend-build /eks-memos/memos/server/router/frontend/dist ./server/router/frontend/dist

RUN go build -ldflags="-s -w" -o /out/memos ./cmd/memos



FROM alpine:3.20 AS runtime

RUN apk add --no-cache ca-certificates \
  && addgroup -S memos \
  && adduser -S -G memos -u 10001 memos

WORKDIR /usr/local/memos

COPY --from=backend-build /out/memos ./memos

RUN mkdir -p /var/opt/memos && chown -R memos:memos /var/opt/memos

USER memos

ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230

EXPOSE 5230

ENTRYPOINT ["./memos"]
CMD ["--data", "/var/opt/memos"]