FROM linuxserver/qbittorrent

RUN	apk update \
	&& apk upgrade \
	&& apk add --no-progress --no-cache chromaprint openjdk11 openjdk11-jre zlib-dev libzen \
	libzen-dev libmediainfo libmediainfo-dev \
	&& mkdir -p /filebot /config/filebot/logs /downloads \
	&& cd /filebot \
	&& FILEBOT_VER=$(curl -s https://get.filebot.net/filebot/ | grep -o "FileBot_[0-9].[0-9].[0-9]" | sort | tail -n1) \
 	&& wget "https://get.filebot.net/filebot/${FILEBOT_VER}/${FILEBOT_VER}-portable.tar.xz" -O /filebot/filebot.tar.xz \
	&& tar -xJf filebot.tar.xz \
	&& rm -rf filebot.tar.xz \
	# Fix filebot libs
	&& ln -sf /usr/lib/libzen.so /filebot/lib/Linux-x86_64/libzen.so \
	&& ln -sf /usr/lib/libmediainfo.so /filebot/lib/Linux-x86_64/libmediainfo.so \
	&& ln -sf /usr/local/lib/lib7-Zip-JBinding.so /filebot/lib/Linux-x86_64/lib7-Zip-JBinding.so \
	&& rm -rf /filebot/lib/FreeBSD-amd64 /filebot/lib/Linux-armv7l /filebot/lib/Linux-i686 /filebot/lib/Linux-aarch64

# Make Filebot binary runable from everywhere:
ENV PATH="/filebot:${PATH}"

# Set the uid/gid:
ENV PUID=99 \
    PGID=100 \
    WEBUI_PORT=

# Various:
ENV FILES_CHECK_PERM=n

# Define variables for Filebot:
ENV FILEBOT_LANG=en \
    FILEBOT_CONFLICT=auto \
    FILEBOT_ACTION=copy \
    FILEBOT_ARTWORK=y \
    FILEBOT_PROCESS_MUSIC=y \
    MUSIC_FORMAT={plex} \
    MOVIE_FORMAT={plex} \
    SERIE_FORMAT={plex} \
    ANIME_FORMAT="animes/{n}/{e.pad(3)} - {t}" \
    FILEBOT_OPTS=-Dnet.filebot.archive.unrar=/usr/bin/unrar \
    EXTRA_FILEBOT_PARAM=

# environment settings
ENV HOME="/data" \
XDG_CONFIG_HOME="/data" \
XDG_DATA_HOME="/data"


# add local files
COPY root/ /
RUN chmod +x /etc/cont-init.d/*
VOLUME ["/data"]
VOLUME ["/downloads"]
VOLUME ["/media"]
EXPOSE 8080
