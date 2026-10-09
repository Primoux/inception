FROM debian:bookworm

ARG UPTIME_KUMA_VERSION=1.23.16

RUN apt-get update && apt-get install -y curl git ca-certificates gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${UPTIME_KUMA_VERSION} \
        https://github.com/louislam/uptime-kuma.git /app

WORKDIR /app

RUN npm ci --omit=dev && node extra/download-dist.js

EXPOSE 3001

CMD ["node", "server/server.js"]
