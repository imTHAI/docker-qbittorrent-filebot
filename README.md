# docker-qbittorrent-filebot
qbittorrent including Filebot tool

For QBittorrent, I used [linuxserver/qbittorrent docker](https://hub.docker.com/r/linuxserver/qbittorrent).

For Filebot, please see https://www.filebot.net


### You can set different variables:

| Variable |  Default value |
| -------- |  ------------- |
| **FILEBOT_LANG** | en
| **FILEBOT_ACTION** | copy
| **FILEBOT_CONFLICT** | auto
| **FILEBOT_ARTWORK** | yes
| **MUSIC_FORMAT** | {plex}
| **MOVIE_FORMAT** | {plex}
| **SERIE_FORMAT** | {plex}
| **ANIME_FORMAT** | animes/{n}/{e.pad(3)} - {t}
| **PUID** | 99
| **PGID** | 100
| **FILES_CHECK_PERM** | no
| **WEBUI** | 8080

### Please READ:
* The default login/password is the default one of an official qbittorrent release: admin/adminadmin
* Set your PUID and PGID according to your system ! I've set 99/100 because it's the default one on unRAID.
* Be aware that {plex} movie format will put movies in Movies folder. Same for Tvshows ({plex} => "/TV Shows"), and for music ({plex} => "/Music"). So if it's not what you want, don't forget to adapt. I personnaly use "movies/{plex.tail}" etc...
* Be carefull with FILES_CHECK_PERM. If you set to yes, it can take a long time to scan your media folder and then you will have to wait before you get the Qbt web interface.
* FILEBOT_ACTION is set to copy by default, so it can take time/disk pace, especialy with big movies. You can change to move | symlink | hardlink | test. But if you set to 'move', you won't seed anymore. If you set to symlink, it doesn't work well with docker volume shares. Well, test what is best for you.
* You can change the webport with the variable WEBUI_PORT. I personnaly use 80.
* Don't forget to add your Filebot license file (psm file) into /data/filebot folder then restart
* Qbt login/password is admin/adminadmin as usual.

### Volumes:

/data : folder for the config
/downloads : folder for downloads
/media : folder for media

### Ports:

 - `8080` (WEBUI)
 - `6881` (PORT_RTORRENT)

## Usage example (I like to set one ip per container, but it's up to you):
```sh
docker run -d --name='qbittorrent-filebot' \
--net='br0' --ip='10.0.1.25' -e TZ="Europe/Paris" \
-e MOVIE_FORMAT='/media/movies/{plex.tail}' \
-e SERIE_FORMAT='/media/series/{plex[1]}/{'\''Season '\''+s}/{plex.name}' \
-e PUID=99 -e PGID=100 \
-e WEBUI_PORT=80 \
-v /mnt/user/media/:/media:rw \
-v /mnt/user/media/downloads/:/downloads:rw \
-v /mnt/user/appdata/qbittorrent-filebot/:/data:rw \
imthai/qbittorrent-filebot
```


