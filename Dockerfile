# Use Ubuntu rolling as base image
FROM ubuntu:24.10

# Set default values for build
ARG PUID=99
ARG PGID=100

# Update packages and install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        gnupg \
        curl \
        apt-transport-https \
        ca-certificates \
        openjdk-21-jre-headless \
        unzip \
        unrar \
        p7zip-full \
        p7zip-rar \
        xz-utils \
        locales \
        mediainfo \
        imagemagick \
        webp \
        file \
        rsync \
        jdupes \
        duperemove \
        libchromaprint-tools \
        gosu && \
    # Add the PPA and install qbittorent-nox
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable && \
    apt-get update && \
    apt-get install -y qbittorrent-nox && \
    # Remove unnecessary packages
    apt-get remove -y \
        man \
        lsb-release && \
    # Clean up the package cache
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Add local files
COPY root/ /

# Directory and Permissions Configuration
RUN mkdir -p \
    /filebot/data \
    /data/filebot/logs \
    /downloads \
    /media \
    /data/qBittorrent && \
    chmod -R 755 /filebot /downloads /data /media && \
    chmod +x /apps/entrypoint.sh /apps/qbittorrent-config-sync.py

# Install FileBot
RUN FILEBOT_VER=$(curl -s https://get.filebot.net/filebot/ | grep -o "FileBot_[0-9].[0-9].[0-9]" | sort | tail -n1) && \
    curl -L "https://get.filebot.net/filebot/${FILEBOT_VER}/${FILEBOT_VER}-portable.tar.xz" -o /filebot/filebot.tar.xz && \
    tar -xJf /filebot/filebot.tar.xz -C /filebot && \
    rm -rf /filebot/filebot.tar.xz

# Create user and group
RUN if ! getent group ${PGID}; then \
        groupadd -g ${PGID} qbtgroup; \
    else \
        groupmod -n qbtgroup $(getent group ${PGID} | cut -d: -f1); \
    fi && \
    useradd -u ${PUID} -g qbtgroup -d /data qbtuser && \
    chown -R qbtuser:qbtgroup /filebot /downloads /data /media


# Set environment variables for execution
# Set the locale
ENV PUID=${PUID} \
    PGID=${PGID} \
    FILES_CHECK_PERM=n \
    FILEBOT_LANG=en \
    FILEBOT_CONFLICT=auto \
    FILEBOT_ACTION=copy \
    FILEBOT_ARTWORK=y \
    FILEBOT_PROCESS_MUSIC=y \
    MUSIC_FORMAT={plex} \
    MOVIE_FORMAT={plex} \
    SERIE_FORMAT={plex} \
    ANIME_FORMAT="animes/{n}/{e.pad(3)} - {t}" \
    EXTRA_FILEBOT_PARAM= \
    HOME="/data" \
    XDG_CONFIG_HOME="/data" \
    XDG_DATA_HOME="/data" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

EXPOSE 8080

# Use this script as entry point
ENTRYPOINT ["/apps/entrypoint.sh"]
