FROM --platform="$BUILDPLATFORM" alpine:3.17.3 as rvx

ARG NODE_ENV=production \
    RVX_VERSION=revanced-extended \
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

WORKDIR /src
RUN apk add --no-cache ca-certificates nodejs yarn git && \
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

FROM alpine:3.17.3
RUN apk add --no-cache ca-certificates tzdata
    
COPY            start.sh              /usr/local/bin/start.sh
COPY --from=rvx /src/rvx-builder      /usr/local/bin/rvx-builder
COPY --from=rv  /src/revanced-builder /usr/local/bin/revanced-builder

ENTRYPOINT ["start.sh"]
HEALTHCHECK CMD (wget -q http://localhost:8000 -O /dev/null) || exit 1