FROM --platform="$BUILDPLATFORM" alpine:3.17.3 as rv

ARG NODE_ENV=production \
    RV_VERSION=v3.9.1 \
    TARGETARCH

WORKDIR /src
RUN apk add --no-cache ca-certificates nodejs yarn git && \
    yarn global add pkg && \
    wget https://gobinaries.com/tj/node-prune -O - | sh && \
    git clone --recursive https://github.com/reisxd/revanced-builder --branch "$RV_VERSION" /src && \
    if [ "$TARGETARCH" = "amd64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=x64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-x64 -C GZip --out-path dist .; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=arm64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-arm64 -C Brotli --out-path dist .; \
    fi && \
    chmod +x /src/dist/revanced-builder

FROM --platform="$BUILDPLATFORM" alpine:3.17.3 as rvx

ARG NODE_ENV=production \
    RVX_VERSION=v3.9.2 \
    TARGETARCH

WORKDIR /src
RUN apk add --no-cache ca-certificates nodejs yarn git && \
    yarn global add pkg && \
    wget https://gobinaries.com/tj/node-prune -O - | sh && \
    git clone --recursive https://github.com/inotia00/rvx-builder --branch "$RVX_VERSION" /src && \
    if [ "$TARGETARCH" = "amd64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=x64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-x64 -C GZip --out-path dist .; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    npm_config_target_platform=linux npm_config_target_arch=arm64 yarn install --no-lockfile && \
    node-prune && \
    yarn cache clean --all && \
    pkg -t alpine-arm64 -C Brotli --out-path dist .; \
    fi && \
    chmod +x /src/dist/rvx-builder

FROM alpine:3.17.3
RUN wget https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk add --no-cache ca-certificates tzdata amazon-corretto-17
COPY --from=rv  /src/dist/revanced-builder /usr/local/bin/revanced-builder
COPY --from=rvx /src/dist/rvx-builder      /usr/local/bin/rvx-builder