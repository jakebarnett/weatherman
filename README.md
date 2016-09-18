# weatherman
A tool that uses youtube-dl to download pages of songs from Soundcloud

## Instructions

### 1. Download youtube-dl

```
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
```

or 

```brew install youtube-dl```

https://rg3.github.io/youtube-dl/download.html

### 2. Clone and install dependencies

```
git clone https://github.com/jakebarnett/weatherman.git
cd weatherman
bundle install
```

### 3. Execute
```
ruby youtube-downloader.rb https://soundcloud.com/producer_i_love/likes
```


