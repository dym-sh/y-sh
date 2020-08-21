#!/bin/bash

## y-sh
# > algorithmically-enhanced youtube-dl wrapper for audio-downloads

## requires
# - `pip install youtube_dl` – the main thing, you should already have it
# - `sudo apt install -y ffmpeg` – to convert files of diffrent formats
# - `cargo install sd` – better `sed`
# - `sudo apt install -y lynx` – to easily scrap web-pages


DEFAULT_PATH='/Data/_'
MUSIC_PATH='/Data/Music'
AUDIOBOOKS_PATH='/Data/Audiobooks/yt'
COMEDY_PATH='/Data/Audiobooks/comedy'

IFS=$'\n'

OPT="$1"
URL="$2"
if [ -z "$URL" ]; then
  OPT=''
  URL="$1"
fi

SITE=` echo "$URL" \
     | sd 'https?://(www\.)?' '' \
     | sd '/.*' '' \
     `
echo "URL : '$URL'"
echo "SITE : '$SITE'"

if [[ "$OPT" == 'F' ]]; then
  youtube-dl "$URL" -F
  exit 0
fi



to_mp3()
{
  for NON_MP3 in "$@"
  do
    OUT=` echo "$NON_MP3" \
        |  sd '(\.\w+)?$' ' [conv].mp3' \
        `
    echo "'$NON_MP3'"
    echo ">> '$OUT'"

    ffmpeg -i "$NON_MP3" \
           -codec:a libmp3lame \
           -qscale:a 2 \
           -loglevel quiet \
           -y "$OUT"
  done
}

get_bandcamp_track()
{
  echo "> > track: '$1'"
  youtube-dl "$1" --force-ipv4 -f mp3-320 \
    -o "$MUSIC_PATH/$ARTIST/%(album)s/%(track_number)02d %(title)s.%(ext)s"
  [ $? -eq 1 ] \
  && youtube-dl "$1" --force-ipv4 -f mp3 \
     -o "$MUSIC_PATH/$ARTIST/%(album)s/%(track_number)02d %(title)s.%(ext)s"
}

get_bandcamp_album()
{
  echo "> > album: '$1'"
  SUBLINKS=(` lynx -dump -listonly -nonumbers "$1" \
            | grep -Eiw "^(https://$SITE/track)" \
            | sd '\?action=download' '' \
            | uniq \
            `)
  for LINK in "${SUBLINKS[@]}" ; do
    get_bandcamp_track "$LINK"
  done
}



case "$SITE" in

'music.youtube.com')
  echo '> youtube-music'
  youtube-dl "$URL" --force-ipv4 -f 251 \
    -o "$MUSIC_PATH/%(artist)s - %(title)s.%(ext)s"
  ;;

youtube.com|youtu.be)
  echo '> youtube'
  case "$OPT" in
  'm')
    echo '> > music'
    youtube-dl "$URL" --force-ipv4 -f 251 \
      -o "$MUSIC_PATH/%(title)s.%(ext)s"
    ;;
  'a')
    echo '> > audiobook'
    youtube-dl "$URL" --force-ipv4 -f 251 \
      -o "$AUDIOBOOKS_PATH/%(title)s.%(ext)s"
    ;;
  'c')
    echo '> > comedy'
    youtube-dl "$URL" --force-ipv4 -f 251 \
      -o "$COMEDY_PATH/%(title)s.%(ext)s"
    ;;
  *)
    echo '> > _video_'
    youtube-dl "$URL" --force-ipv4 \
      -o "$DEFAULT_PATH/%(title)s.%(ext)s"
    ;;
  esac
  ;;

'soundcloud.com')
  echo '> soundcloud'
  ARTIST=` echo "$URL" \
         | sd 'https?://(www.)?soundcloud.com/' '' \
         | sd '/.*' '' \
         `
  echo "ARTIST : '$ARTIST'"
  youtube-dl "$URL" --force-ipv4 --add-metadata \
    --postprocessor-args "-metadata artist='$ARTIST'" \
    -o "$MUSIC_PATH/$ARTIST/%(title)s.%(ext)s"

  ls -A "$MUSIC_PATH/$ARTIST/**/*.wav"
  [ $? -eq 0 ] \
    && to_mp3 "$MUSIC_PATH/$ARTIST/**/*.wav"
  [ $? -eq 0 ] \
    && rm "$MUSIC_PATH/$ARTIST/**/*.wav"
  ;;

*.bandcamp.com)
  echo '> bandcamp'
  ARTIST=` echo "$SITE" \
         | sd '\.bandcamp\.com.*' '' \
         `
  if [ -z "$ARTIST" ]; then
    ARTIST="$SITE"
  fi
  echo "ARTIST : '$ARTIST'"

  if [[ "$URL" =~ '/track/' ]]; then
    get_bandcamp_track "$URL"
  elif [[ "$URL" =~ '/album/' ]]; then
    get_bandcamp_album "$URL"
  else
    echo '> > discography'
    SUBLINKS=(` lynx -dump -listonly -nonumbers "$URL" \
              | grep -Eiw "^(https://$SITE/(album|track))" \
              | sd '\?action=download' '' \
              | uniq \
              `)
    for LINK in "${SUBLINKS[@]}" ; do
      if [[ "$LINK" =~ '/track/' ]]; then
        get_bandcamp_track "$LINK"
      elif [[ "$LINK" =~ '/album/' ]]; then
        get_bandcamp_album "$LINK"
      fi
    done
  fi

  RENAME_LIST=(` ls -RA $MUSIC_PATH/$ARTIST/NA/* `)
  if [ $? -eq 0 ]; then
    echo "files in the album /NA/: '${RENAME_LIST[@]}'"
    for RENAME_FROM in "${RENAME_LIST[@]}"; do
      RENAME_TO=` echo "$RENAME_FROM" \
                | sd '/NA/NA ' '/' \
                `
    if [[ "$RENAME_FROM" != "$RENAME_TO" ]]; then
      echo "'$RENAME_FROM'"
      echo ">> '$RENAME_TO'"
      mv "$RENAME_FROM" "$RENAME_TO"
    fi
    done
    rmdir "$MUSIC_PATH/$ARTIST/NA/"
  fi

  ;;

'twitter.com')
  echo '> twitter'
  CLEAN_URL=` echo "$URL" \
            | sd 'https?://(www.)?twitter.com/' '' \
            | sd -- '/status/' '--' \
            | sd '/?\?.*' '' \
            `
  echo "CLEAN_URL : '$CLEAN_URL'"
  youtube-dl "$URL" --force-ipv4 \
    -o "$DEFAULT_PATH/$CLEAN_URL.%(ext)s"
  ;;

*)
  echo '> _default_'
  youtube-dl "$URL" --force-ipv4 \
    -o "$DEFAULT_PATH/%(title)s.%(ext)s"
  ;;

esac
