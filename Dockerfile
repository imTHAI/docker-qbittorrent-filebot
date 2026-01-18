# --- Step 1: Builder (Fetch & Prepare Binaries) ---
FROM ubuntu:24.04 AS builder

# Prevent interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal tools required for fetching assets
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    xz-utils \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download the latest static qBittorrent binary (Self-contained, no dependencies needed)
RUN curl -fSL "https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox" -o /qbittorrent-nox && \
    chmod +x /qbittorrent-nox

# Download and extract the latest FileBot portable version
RUN mkdir -p /opt/filebot && \
    FILEBOT_VER=$(curl -s https://get.filebot.net/filebot/ | grep -o "FileBot_[0-9].[0-9].[0-9]" | sort | tail -n1) && \
    curl -fSL "https://get.filebot.net/filebot/${FILEBOT_VER}/${FILEBOT_VER}-portable.tar.xz" -o /tmp/filebot.tar.xz && \
    tar -xJf /tmp/filebot.tar.xz -C /opt/filebot && \
    rm /tmp/filebot.tar.xz

# --- Step 2: Final Image (Hardened Wolfi Base) ---
# Wolfi provides a minimal footprint with enterprise-grade security patching
FROM cgr.dev/chainguard/wolfi-base:latest

# Install necessary runtime dependencies
# Note: Wolfi uses 'apk' but provides glibc-compatible binaries
RUN apk add --no-cache \
    openjdk-21 \
    python-3 \
    bash \
    tini \
    su-exec \
    shadow \
    mediainfo \
    curl \
    7zip \
    glibc-locale-en

# Library compatibility: Create symlinks for FileBot (which expects Ubuntu paths)
# and a legacy symlink for backward compatibility with older scripts
RUN ln -s /opt/filebot /filebot && \
    ln -s /usr/lib/libcurl.so.4 /usr/lib/libcurl-gnutls.so.4 && \
    ln -s /usr/lib/libmediainfo.so.0 /usr/lib/libmediainfo.so.4 || true

# Initialize application structure
RUN mkdir -p /apps /data /media /downloads /src /opt/filebot

# Copy binaries and portable apps from the builder stage
COPY --from=builder /qbittorrent-nox /usr/bin/qbittorrent-nox
COPY --from=builder /opt/filebot /opt/filebot

# Copy local configurations and scripts (Ensure a .dockerignore exists to skip garbage)
COPY root/ /

# Ensure execution rights (Set during build to maintain immutability)
RUN chmod +x /apps/entrypoint.sh \
    /apps/qbittorrent-config-sync.py \
    /usr/bin/qbittorrent-nox \
    /opt/filebot/filebot.sh

# Environment Setup
# PUID/PGID allow the entrypoint script to map permissions at runtime
ENV PUID=99 \
    PGID=100 \
    FILEBOT_LANG=en \
    FILEBOT_CONFLICT=auto \
    FILEBOT_ACTION=copy \
    FILEBOT_ARTWORK=y \
    FILEBOT_PROCESS_MUSIC=y \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
    PATH="/usr/lib/jvm/java-21-openjdk/bin:/opt/filebot:${PATH}" \
    HOME=/data \
    XDG_CONFIG_HOME=/data \
    XDG_DATA_HOME=/data

# Expose WebUI and BitTorrent traffic ports
EXPOSE 8080 6881/tcp 6881/udp

# Use Tini to prevent zombie processes and handle signals (SIGTERM/SIGINT) correctly
ENTRYPOINT ["/sbin/tini", "--", "/apps/entrypoint.sh"]
