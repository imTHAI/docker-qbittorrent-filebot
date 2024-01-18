# docker-qBittorrent-filebot
qBittorrent including Filebot tool

For qBittorrent, I used [linuxserver/qbittorrent docker](https://hub.docker.com/r/linuxserver/qbittorrent).

For Filebot, please see https://www.filebot.net


### You can set different variables:

| Variable |  Default value |
| -------- |  ------------- |
| **FILEBOT_LANG** | en
| **FILEBOT_ACTION** | copy
| **FILEBOT_CONFLICT** | auto
| **FILEBOT_ARTWORK** | yes
| **MUSIC_FORMAT** | {artist} - {t}
| **MOVIE_FORMAT** | {plex.id}
| **SERIE_FORMAT** | {plex.id}
| **ANIME_FORMAT** | animes/{n}/{e.pad(3)} - {t}
| **PUID** | 99
| **PGID** | 100
| **FILES_CHECK_PERM** | no
| **WEBUI** | 8080

### Please READ:
* Set your PUID and PGID according to your system ! I've set 99/100 because it's the default one on unRAID.
* Be aware that {plex} movie format will put movies in Movies folder. Same for Tvshows ({plex} => "/TV Shows"), and for music ({plex} => "/Music"). So if it's not what you want, don't forget to adapt. I personally use "movies/{~plex.id}", "tvshows/{~plex.id}" etc...
* Be carefull with FILES_CHECK_PERM. If you set to yes, it can take a long time to scan your media folder and then you will have to wait before you get the Qbt web interface.
* FILEBOT_ACTION is set to copy by default, so it can take time/disk space, especialy with big movies. You can change to copy | move | symlink | hardlink | keeplink | test. But if you set to 'move', you won't seed anymore. Plex won't work with the symlinks. For hardlink your torrent downloads and Media Library must be on the same filesystem **AND** your input/output paths must be on the same docker volume because docker treats each volume mount as a separate fs. The keeplink is a Filebot concept and corresponds to a reversed symlink. It works with Plex and the symlink works with qBt.  
* You can change the webport with the variable WEBUI_PORT. I personally use 80. (But don't forget port mapping if you use bridge network rather than a dedicated ip)
* Don't forget to add your Filebot license file (psm file) into /data/filebot folder then restart
* Qbt login/password is admin/adminadmin by default.
* If you want to customize the script that calls filebot (fb.sh) , set the variable custom=1 inside the script, it will no longer be replaced when restarted.

### Volumes:

- /data : folder for the config
- /downloads : folder for downloads
- /media : folder for media

### Ports:

 - `8080` (WEBUI)
 - `6881` (PORT_RTORRENT)

## Usage example (I like to set one ip per container, but it's up to you):
```sh
docker run -d --name='qbittorrent-filebot' \
--net='br0' --ip='10.0.1.25' -e TZ="Europe/Paris" \
-e MOVIE_FORMAT='movies/{~plex.id}' \
-e SERIE_FORMAT='tvshows/{~plex.id}' \
-e PUID=99 -e PGID=100 \
-e WEBUI_PORT=80 \
-v /mnt/user/media:/media:rw \
-v /mnt/user/downloads:/downloads:rw \
-v /mnt/user/appdata/qbittorrent-filebot:/data:rw \
imthai/qbittorrent-filebot
```


