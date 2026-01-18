#!/bin/bash

# 1. User management without 'getent' (Wolfi/Unraid compatible)
if ! id -g qbtgroup &>/dev/null; then
    groupadd -g ${PGID} qbtgroup
else
    # Rename group if it already exists to match our naming
    groupmod -n qbtgroup $(id -gn $(id -u -n ${PUID} 2>/dev/null || echo "99") 2>/dev/null || echo "qbtgroup") 2>/dev/null
fi

if ! id -u qbtuser &>/dev/null; then
    useradd -K MAIL_DIR=/dev/null -u ${PUID} -g qbtgroup -d /data qbtuser
fi

# 2. Selective permissions for faster startup
# We only chown application-critical folders, not the whole /media library
echo "Fixing application permissions..."
mkdir -p /data/qBittorrent /data/filebot/logs
chown -R ${PUID}:${PGID} /data /apps /opt/filebot /src

# 3. FileBot License Activation
# Looks for a .psm file in /data/ to activate the license
license=$(find /data/ -iname "*.psm" | head -n1)
if [ -n "${license}" ]; then
    echo ">> License detected: ${license}"
    # Run activation as the non-root user
    su-exec ${PUID}:${PGID} /opt/filebot/filebot.sh --license "${license}"
else
    echo -e "********\n\n>> No license detected for FILEBOT\n>> Please put your license psm file in /data/filebot folder\n\n********\n"
fi

# 4. Backward Compatibility: Fix paths in existing fb.sh
script=/data/filebot/fb.sh
if [ ! -f "$script" ] || [ -z "$(grep "custom=1" "$script")" ]; then
    cp /src/fb.sh /data/filebot
    # Patch legacy path (/filebot/) to new hardened path (/opt/filebot/)
    sed -i 's|/filebot/filebot.sh|/opt/filebot/filebot.sh|g' /data/filebot/fb.sh
    chown ${PUID}:${PGID} /data/filebot/fb.sh
    chmod +x /data/filebot/fb.sh
fi

# 5. Configuration Sync
# Restore default config if missing and run the Python sync script
if [ ! -f /data/qBittorrent/qBittorrent.conf ]; then
    cp /src/qBittorrent_default.conf /data/qBittorrent/qBittorrent.conf
fi
python3 "/apps/qbittorrent-config-sync.py"

# 6. Start qBittorrent
echo "Starting qBittorrent..."
# Use su-exec to drop root privileges and start qBt as PUID:PGID
# --profile=/data ensures the config is read from the correct mapped volume
exec su-exec ${PUID}:${PGID} qbittorrent-nox --confirm-legal-notice
