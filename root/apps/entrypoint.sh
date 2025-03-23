#!/bin/bash

# Create necessary directories
mkdir -p /data/qBittorrent /data/filebot/logs

# Copy default config file if not exists
if [ ! -f /data/qBittorrent/qBittorrent.conf ]; then
    cp /src/qBittorrent_default.conf /data/qBittorrent/qBittorrent.conf
fi

# If user customized script, don't touch it
script=/data/filebot/fb.sh
if [ ! -f "$script" ] || [ -z "$(grep "custom=1" "$script")" ]; then
    cp /src/fb.sh /data/filebot
fi

# Set proper permissions
chown -R qbtuser:qbtgroup /data /filebot
chmod +x /data/filebot/fb.sh

# Set the license
license=$(find /data/ -iname "*.psm" | head -n1)
if [ -n "${license}" ]; then
    sh /filebot/filebot.sh --license=${license}
else
    echo -e "********\n\n>> No license detected for FILEBOT\n>> Please put your license psm file in /data/filebot folder\n\n********\n"
fi

# Set extra filebot parameters
if [ -n "${EXTRA_FILEBOT_PARAM}" ]; then
    sed -i '/output/a "${EXTRA_FILEBOT_PARAM}" \\' /data/filebot/fb.sh
else
    sed -i '/EXTRA_FILEBOT_PARAM/d' /data/filebot/fb.sh
fi

# Check files permissions if requested (default is no):
# Be aware that it can take a long time if you have a large /media folder
# and you'll have to wait before getting the web interface of qbittorrent!
if [[ ${FILES_CHECK_PERM} =~ [yY] ]]; then
    chown -R ${PUID}:${PGID} /media
fi

# Path to the config sync script
CONFIG_SYNC_SCRIPT="/apps/qbittorrent-config-sync.py"

echo "Starting qBittorrent configuration sync..."
# Run the configuration sync script
python3 "$CONFIG_SYNC_SCRIPT"
echo "Configuration sync completed."

# Start qBittorrent
echo "Starting qBittorrent..."
exec gosu qbtuser:qbtgroup qbittorrent-nox
