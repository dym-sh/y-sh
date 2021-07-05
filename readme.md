# y

> algorithmically-enhanced [youtube-dl](https://yt-dl.org) wrapper for audio-downloads


## install
1. look at [`install.sh`](./install.sh) file for instructions
2. adjust `PREFIX` at wish
3. make sure the final directory is on `$PATH`

## use
`y https://orax.bandcamp.com/track/ectoplasmic`

(adjust [config.sh](./config.sh) file to set your prefered download paths)


## requirments
- [`youtube_dl`](https://github.com/ytdl-org/youtube-dl) – the main thing
- [`ffmpeg`](https://ffmpeg.org/download.html) – to convert files of diffrent formats
- [`sd`](https://github.com/chmln/sd) – a better `sed`
- [`lynx`](https://github.com/lynx/lynx) – to easily scrap web-pages


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
