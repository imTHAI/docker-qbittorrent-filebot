# 🐳 docker-qBittorrent-filebot
![Docker Pulls](https://img.shields.io/docker/pulls/imthai/qbittorrent-filebot)
![Docker Stars](https://img.shields.io/docker/stars/imthai/qbittorrent-filebot)

This Docker image combines qBittorrent with the Filebot tool for automated media management. 🚀

## 📚 Table of Contents
- [Description](#description)
- [Variables](#variables)
- [Important Notes](#important-notes)
- [Volumes](#volumes)
- [Ports](#ports)
- [Usage Example](#usage-example)

## 📝 Description

This image is based on Ubuntu and includes the latest stable release of qBittorrent and Filebot. It provides an all-in-one solution for downloading and organizing media files. 🎬🎵

For more information about Filebot, please visit https://www.filebot.net

## 🔧 Variables

You can customize the behavior of the container using the following variables:

| Variable | Default value | Description |
| -------- | ------------- | ----------- |
| FILEBOT_LANG | en | Language for Filebot |
| FILEBOT_ACTION | copy | Action to perform (copy, move, symlink, hardlink, keeplink, test) |
| FILEBOT_CONFLICT | auto | Conflict resolution strategy |
| FILEBOT_ARTWORK | yes | Whether to fetch artwork |
| MUSIC_FORMAT | {plex} | Naming format for music files |
| MOVIE_FORMAT | {plex} | Naming format for movie files |
| SERIE_FORMAT | {plex} | Naming format for TV series files |
| ANIME_FORMAT | animes/{n}/{e.pad(3)} - {t} | Naming format for anime files |
| PUID | 99 | User ID for file permissions |
| PGID | 100 | Group ID for file permissions |
| FILES_CHECK_PERM | no | Whether to check file permissions on startup |
| WEBUI | 8080 | Port for the web interface |

## ⚠️ Important Notes

- Set your PUID and PGID according to your system. The default values (99/100) are for unRAID's nobody/users.
- The {plex} format will organize files into specific folders (Movies, TV Shows, Music). Adjust if needed.
- Using {plex.id} instead of {plex} includes the numeric ID in the folder name, which is more machine-friendly.
- FILEBOT_ACTION is set to "copy" by default. Be aware of the implications when changing this setting.
- Add your Filebot license file (psm file) to /data/filebot folder and restart the container.
- Default qBittorrent login is "admin". A new password is generated at each startup (check logs) until you set a permanent one.
- To customize the fb.sh script, set custom=1 inside the script to prevent overwriting on restart.
- Setting FILES_CHECK_PERM to "yes" may significantly increase startup time.
- If you change the default ports in the qBittorrent config, update your Docker port mappings accordingly.

**Important note about FILEBOT_ACTION:**
If you choose to set FILEBOT_ACTION to "MOVE" or "HARDLINK", you need to adapt your configuration:
1. Use a single general mount point. For example (if you're using unRAID), map /onemount (container) to /mnt/user (host).
2. Adjust the download folder in qBittorrent settings. For example, set it to /onemount/downloads (corresponding to your /mnt/user/downloads).
3. Modify the fb.sh script (located in the filebot folder). Change the output to /onemount/media (which corresponds to your /mnt/user/media).

## 📂 Volumes

- /data: Configuration folder
- /downloads: Download folder
- /media: Media folder

## 🔌 Ports

- 8080/tcp: Web UI
- 6881/tcp: Incoming torrent connections
- 6881/udp: Incoming torrent connections

Port 8080 is mapped by default for the WEBUI, and ports 6881 (tcp & udp) are used for incoming torrent connections. These port mappings are required when using Docker's network bridge mode.

Important notes:
- If you change these ports in the qBittorrent config (via WEBUI for example), remember to update the corresponding port bindings in your Docker run command or compose file.
- If you're using a dedicated IP or network host mode, you can ignore or omit these port bindings.

## 🚀 Usage Example
```sh
docker run -d –name=‘qbittorrent-filebot’ 
–net=‘br0’ –ip=‘10.3.12.21’ –ip6=‘2a01:d33b:f44f:985a:10:2:12:21’ 
-e TZ=“Europe/Paris” 
-e ‘FILEBOT_ACTION’=‘copy’ 
-e ‘FILEBOT_LANG’=‘en’ 
-e ‘MOVIE_FORMAT’=’{plex}’ 
-e ‘SERIE_FORMAT’=’{plex}’ 
-e ‘PUID’=‘99’ 
-e ‘PGID’=‘100’ 
-v ‘/mnt/user/media/’:’/media’:‘rw’ 
-v ‘/mnt/user/downloads’:’/downloads’:‘rw’ 
-v ‘/mnt/user/appdata/qbittorrent-filebot/’:’/data’:‘rw’ 
‘imthai/qbittorrent-filebot’
```

Note: This example uses a custom network configuration. Adjust according to your needs. 🛠️
