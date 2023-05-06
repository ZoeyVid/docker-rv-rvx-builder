FROM --platform="$BUILDPLATFORM" alpine:3.17.3 as rvx

ARG NODE_ENV=production \
    RVX_VERSION=v3.9.2 \
    TARGETARCH

COPY rvx.patch /rvx.patch
WORKDIR /src
RUN apk add --no-cache ca-certificates nodejs yarn git && \
    yarn global add pkg && \
    wget https://gobinaries.com/tj/node-prune -O - | sh && \
    git clone --recursive https://github.com/inotia00/rvx-builder --branch "$RVX_VERSION" /src && \
    git apply /rvx.patch && \
    if [ "$TARGETARCH" = "amd64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=x64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-x64 -C Brotli --output rvx-builder /src; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=arm64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-arm64 -C Brotli --output rvx-builder /src; \
    fi && \
    chmod +x /src/rvx-builder

FROM --platform="$BUILDPLATFORM" alpine:3.17.3 as rv

ARG NODE_ENV=production \
    RV_VERSION=v3.9.1 \
    TARGETARCH

COPY rv.patch /rv.patch
WORKDIR /src
RUN apk add --no-cache ca-certificates nodejs yarn git && \
    yarn global add pkg && \
    wget https://gobinaries.com/tj/node-prune -O - | sh && \
    git clone --recursive https://github.com/reisxd/revanced-builder --branch "$RV_VERSION" /src && \
    git apply /rv.patch && \
    if [ "$TARGETARCH" = "amd64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=x64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-x64 -C Brotli --output revanced-builder /src; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=arm64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-arm64 -C Brotli --output revanced-builder /src; \
    fi && \
    chmod +x /src/revanced-builder

FROM alpine:3.17.3
RUN wget https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk add --no-cache ca-certificates tzdata curl amazon-corretto-17
    
COPY            start.sh              /usr/local/bin/start.sh
COPY --from=rvx /src/rvx-builder      /usr/local/bin/rvx-builder
COPY --from=rv  /src/revanced-builder /usr/local/bin/revanced-builder

ENTRYPOINT ["start.sh"]
HEALTHCHECK CMD (curl -sI http://localhost:81 -o /dev/null && curl -sI http://localhost:82 -o /dev/null) || exit 1