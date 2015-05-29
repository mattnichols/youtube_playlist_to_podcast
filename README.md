# youtube_playlist_to_podcast

This utility generates a podcast stream on Huffduffer from a playlist on YouTube. It does this by downloading the video, extracting and tagging the audio, uploading the audio to your Dropbox account and posting the audio file to your Huffduffer account. Nerdy? Yes!

## Prerequisites
* Ruby (tested on mri 2.1.1p76)
* Bundler rubygem
* Homebrew

## Setup
* Clone or download repository
* From source directory, run ./setup
* Edit settings.private.yaml. See Configuration section.

## Configuration

Here is an example configuration. 

### credentials

This section should contain your dropbox and Huffduffer credentials

### playlists

You can define as many playlists as you want. In the example you will see 2 playlists defined:

The *first playlist* is watching a user-defined playlist with no filters (all videos will be processed) and is set to save the video file to dropbox as well (this is defaulted to false)

The *second playlist* will watch The Dice Tower's Top 10 Playlist. It will filter out the Mage Wars, Summoner Wars, and Smash Up top 10 videos

Example configuration:
  
    :credentials:
      :dropbox:
        :appkey: 'aosidfjaposdijf'
        :secret: 'ssssshhhhhh'
      :huffduffer:
        :login: 'bob'
        :password: 'I$YourUnc13'
    :playlists:
    - :id: PLVlZ87_DDoM09-yp3ExHRSPTU7XamSVC4
      :type: playlist
      :tag: dicetowerqanda
      :savevideo: true
      :filters:
        :includes:
        - "q & a"
        :excludes: []
    - :id: PL97ADFA21D301E54F
      :type: playlist
      :tag: dicetowertopten
      :filters:
        :includes:
        - top ten
        - top 10
        :excludes:
        - mage wars
        - Summoner Wars
        - Smash Up

## Running

### List videos that will be processed

    ./pc list
  
### Process videos

    ./pc

## To Do

* Add commandline help
* Get rid of use of Watir for Huffduffer post. Switch to headless browser or use Huffduffer API


## License

The MIT License (MIT)

Copyright (c) 2015 Alien Abducted Software, LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
