FROM --platform="$BUILDPLATFORM" node:20.3.1-alpine3.17 as rvx

ARG NODE_ENV=production \
    RVX_VERSION=revanced-extended \
    TARGETARCH

WORKDIR /src
RUN apk add --no-cache ca-certificates git && \
    yarn global add pkg && \
    wget https://gobinaries.com/tj/node-prune -O - | sh && \
    git clone --recursive https://github.com/inotia00/rvx-builder --branch "$RVX_VERSION" /src && \
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

FROM --platform="$BUILDPLATFORM" node:20.3.1-alpine3.17 as rv

ARG NODE_ENV=production \
    RV_VERSION=v3.9.3 \
    TARGETARCH

WORKDIR /src
RUN apk add --no-cache ca-certificates git && \
    yarn global add pkg && \
    wget https://gobinaries.com/tj/node-prune -O - | sh && \
    git clone --recursive https://github.com/reisxd/revanced-builder --branch "$RV_VERSION" /src && \
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

FROM alpine:3.18.2
WORKDIR /data
RUN wget https://apk.corretto.aws/amazoncorretto.rsa.pub -O /etc/apk/keys/amazoncorretto.rsa.pub && \
    echo "https://apk.corretto.aws" | tee -a /etc/apk/repositories && \
    apk add --no-cache ca-certificates tzdata amazon-corretto-17
    
COPY            start.sh              /usr/local/bin/start.sh
COPY --from=rvx /src/rvx-builder      /usr/local/bin/rvx-builder
COPY --from=rv  /src/revanced-builder /usr/local/bin/revanced-builder

ENTRYPOINT ["start.sh"]
HEALTHCHECK CMD (wget -q http://localhost:8000 -O /dev/null) || exit 1
