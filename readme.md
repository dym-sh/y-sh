# y

> algorithmically-enhanced [youtube-dl](https://yt-dl.org)[[c](https://github.com/blackjack4494/yt-dlc)] wrapper for audio-downloads


## [install](./install.sh) and use
``` sh
PREFIX='~/.local'

git clone --depth 1 \
  https://dym.sh/y/ \
  $PREFIX/src/y/

chmod +x $PREFIX/src/y/y.sh
ln -s $PREFIX/src/y/y.sh \
      $PREFIX/bin/y
```

`y https://orax.bandcamp.com/track/ectoplasmic`

(adjust [config](./config.sh) file to set your prefered download paths)


## requires
- `pip install youtube_dl` \
  or `python3 -m pip install --upgrade youtube-dlc` \
  – the main thing
- `sudo apt install -y ffmpeg` – to convert files of diffrent formats
- `cargo install sd` – a better `sed`
- `sudo apt install -y lynx` – to easily scrap web-pages


## site-specific improvements

### bandcamp
1. prefers mp3-320 (checks every track)
2. downloads entire discography if given root-domain or `/music` url

### twitter
file-name is now twitter-username and tweet-id
(instead of full text of a tweet, which can result in strings over 255 characters long, aborting the entire process)

### reddit
file-name is now subreddit, post-id, and url-slug
(instead of full text of a title, which can result in strings over 255 characters long, aborting the entire process)

### youtube
allows to set several predetermined filesystem-paths to keep file-categories separately:

- `y m <youtube_URL>` – music (automatically chosen for `music.youtube.com`)
- `y c <youtube_URL>` – comedy-tracks
- `y a <youtube_URL>` – audiobooks

### soundcloud
1. occasional wav-files are converted to mp3 320kb/s
2. artist is set based on url (instead of having none by default)


## tags
- #script
- #bash


## mirrors
- https://github.com/dym-sh/y
- https://gitlab.com/dym-sh/y
- https://dym.sh/y
- hyper://___ /[?](https://beakerbrowser.com)


## license
[mit](./license)
