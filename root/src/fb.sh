#!/bin/bash
# Future feature
#if [ ! -f /filebot/osdb.loggedin ]; then
# printf "$OSDB_USER\n$OSDB_PASSWD\n" | /filebot/filebot.sh -script fn:configure
# touch /filebot/osdb.loggedin
#fi

# Set this to 1 if you want to customize the fb.sh script. So it won't be reset at restart.
custom=0

/filebot/filebot.sh \
-script fn:amc \
--output /media \
--lang "$FILEBOT_LANG" \
--action "$FILEBOT_ACTION" \
--conflict "$FILEBOT_CONFLICT" \
--log-file /data/filebot/filebot.log \
--def excludeList=/data/filebot/amc-exlude-list.txt \
-non-strict \
--def \
unsorted=y \
music="$FILEBOT_PROCESS_MUSIC" \
musicFormat="$MUSIC_FORMAT" \
artwork="$FILEBOT_ARTWORK" \
movieFormat="$MOVIE_FORMAT" \
seriesFormat="$SERIE_FORMAT" \
animeFormat="$ANIME_FORMAT" \
ut_kind=multi \
ut_dir="$1" \
ut_title="$2" \
ut_label="$3"
