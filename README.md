# Youtube Caption Clipper

Downloads youtube videos and cuts clips of video where captions match a search phrase.

This was a weekend project so don't expect too much out of it.

## Installation

This script requires that you have ffmpeg installed and available on your path.

You will need to have `grunt-cli` installed globally to install this. Install it with `npm install -g grunt-cli`. Then clone this repository and run `npm install && grunt && npm link`.


## Usage

`ytccc [video URL] [search term]`

 - `[video URL]`: The URL of the youtube video you want to cut
 - `[search term]`: The word you want to search for in the captions

This will download the captions and the full video at the URL, and then create clips from the original video where the captions contain `[search term]`.

## Building

To compile the source just run `grunt`.
