# docker-qbittorrent-filebot
qbittorrent including Filebot tool

For QBittorrent, I used [linuxserver/qbittorrent docker](https://hub.docker.com/r/linuxserver/qbittorrent).

For Filebot, please see https://www.filebot.net


You can set different variables:

| Variable |  Default value |
| -------- |  ------------- |
| **FILEBOT_LANG** | en
| **FILEBOT_ACTION** | copy
| **FILEBOT_CONFLICT** | auto
| **FILEBOT_ARTWORK** | yes
| **MUSIC_FORMAT** | {plex}
| **MOVIE_FORMAT** | {plex}
| **SERIE_FORMAT** | {plex}
| **ANIME_FORMAT** | {plex}
| **PUID** | 99
| **PGID** | 100
| **FILES_CHECK_PERM** | no

#### Please READ:
* Set your PUID and PGID according to your system ! I've set 99/100 because it's the default one on unRAID.
* Be aware that {plex} movie format will put movies in Movies folder. So if it's not what you want, don't forget to adapt. I personnaly use "movies/{plex.tail}"
* Be carefull with FILES_CHECK_PERM. If you set to yes, it can take a long time to scan your media folder and then you will have to wait before you get the Qbt web interface.
* FILEBOT_ACTION is set to copy by default, so it can take time/disk pace, especialy with big movies. You change change to move | symlink | hardlink | test. But if you set to move, you can't seed. If you set to symlink, it doesn't work well with docker volume shares. Test what is best for you.
