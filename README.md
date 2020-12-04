A script I whipped up to search wikipedia for interesting radio stations. It
downloads all radio station pages on wikipedia and searches them for the
search terms specified, excluding pages that contain blacklisted search terms.

The `dl.py` script requires `lxml`. The files it creates are included in this
repo so that you don't have to run it if you don't want (it takes a while).

The `make.sh` script does the searching. It searches using hard-coded regexes,
so twek it to your liking. The output of the three example searches that script
produces are included as html files in this repo.

