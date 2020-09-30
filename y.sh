#!/bin/bash

## y
# > algorithmically-enhanced youtube-dl[c] wrapper for audio-downloads

## requires
# - `pip install youtube_dl`
#   or `python3 -m pip install --upgrade youtube-dlc`
#   – the main thing, you should already have it
# - `sudo apt install -y ffmpeg` – to convert files of diffrent formats
# - `cargo install sd` – better `sed`
# - `sudo apt install -y lynx` – to easily scrap web-pages


YDL()
{
  which youtube-dlc
  if [ $? -eq 0 ]; then
    youtube-dlc --force-ipv4 $@
    return
  fi

  which youtube-dl
  if [ $? -eq 0 ]; then
    youtube-dl --force-ipv4 $@
    return
  fi

  echo "no youtube-dl[c] found, install it with
    'python3 -m pip install --upgrade youtube-dlc'
    "
  exit 1
}

# load config
cd `realpath "$0" | xargs dirname`
. config.sh

# use new-line as separator of array elements
IFS=$'\n'

# parse cli options
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
if [ OPT == 'band' ]; then
  SITE='_CNAME.bandcamp.com'
fi

echo "URL : '$URL'"
echo "SITE : '$SITE'"

if [ "$OPT" == 'F' ]; then
  YDL "$URL" -F
  exit 1
fi



wav_to_mp3()
{
  for WAV in "$@"
  do
    MP3=` echo "$WAV" \
        | sd '\.wav$' ' [conv].mp3' \
        `
    echo "'$WAV'"
    echo ">> '$MP3'"

    ffmpeg -i "$WAV" \
           -codec:a libmp3lame \
           -qscale:a 2 \
           -loglevel quiet \
           -y "$MP3"
  done
}

get_bandcamp_track()
{
  echo "> > track: '$1'"
  YDL "$1" -f mp3-320 \
    -o "$MUSIC_PATH/$ARTIST/%(album)s/%(track_number)02d %(title)s.%(ext)s"
  [ $? -eq 1 ] \
    && YDL "$1" -f mp3 \
       -o "$MUSIC_PATH/$ARTIST/%(album)s/%(track_number)02d %(title)s.%(ext)s"
}

get_bandcamp_album()
{
  echo "> > album: '$1'"
  SUBLINKS=(` lynx -dump -listonly -nonumbers "$1" \
            | grep -Eiw "^(https://$SITE/track)" \
            | sd '(\?|#).+$' '' \
            | sort -u \
            `)
  for LINK in "${SUBLINKS[@]}" ; do
    get_bandcamp_track "$LINK"
  done
}



case "$SITE" in

'music.youtube.com')
  echo '> youtube-music'
  YDL "$URL" -f 251 \
    -o "$MUSIC_PATH/%(artist)s - %(title)s.%(ext)s"
  ;;

youtube.com|youtu.be)
  echo '> youtube'
  case "$OPT" in
  'm')
    echo '> > music'
    YDL "$URL" -f 251 \
      -o "$MUSIC_PATH/%(title)s.%(ext)s"
    ;;
  'a')
    echo '> > audiobook'
    YDL "$URL" -f 251 \
      -o "$AUDIOBOOKS_PATH/%(title)s.%(ext)s"
    ;;
  'c')
    echo '> > comedy'
    YDL "$URL" -f 251 \
      -o "$COMEDY_PATH/%(title)s.%(ext)s"
    ;;
  *)
    echo '> > _video_'
    YDL "$URL" \
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
  YDL "$URL" --add-metadata \
    --postprocessor-args "-metadata artist='$ARTIST'" \
    -o "$MUSIC_PATH/$ARTIST/%(title)s.%(ext)s"

  WAV_FILES=(` ls -RAd $MUSIC_PATH/$ARTIST/*.wav `)
  [ $? -eq 0 ] \
    && wav_to_mp3 "$WAV_FILES"
  [ $? -eq 0 ] \
    && rm "$WAV_FILES"
  ;;

*.bandcamp.com)
  echo '> bandcamp'
  ARTIST=''
  if [ OPT == 'band' ]; then
    ARTIST=` echo "$URL" \
           | sd '^https?://(www\.)?' '' \
           | sd '/.*$' '' \
           | sd '\..+$' '' \
           `
     SITE=` echo "$URL" \
          | sd '^https?://(www\.)?' '' \
          | sd '/.*$' '' \
          `
  else
    ARTIST=` echo "$SITE" \
           | sd '\.bandcamp\.com.*' '' \
           `
    if [ -z "$ARTIST" ]; then
      ARTIST="$SITE"
    fi
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

  RENAME_LIST=(` ls -RAd $MUSIC_PATH/$ARTIST/NA/* `)
  if [ $? -eq 0 ]; then
    for RENAME_FROM in "${RENAME_LIST[@]}"; do
      RENAME_TO=` echo "$RENAME_FROM" \
                | sd '/NA/NA ' '/' \
                `
      if [ "$RENAME_FROM" != "$RENAME_TO" ]; then
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
  YDL "$URL" -o "$DEFAULT_PATH/$CLEAN_URL.%(ext)s"
  ;;

*)
  echo '> _default_'
  YDL "$URL" -o "$DEFAULT_PATH/%(title)s.%(ext)s"
  ;;

esac
