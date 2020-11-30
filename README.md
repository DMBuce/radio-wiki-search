A script I whipped up to search wikipedia for interesting radio stations. It
parses the wikipedia page for NPR and independent radio stations, then
searches the summary of each individual radio station's wiki page for the
search terms specified, excluding pages that contain blacklisted search terms.

The script requires a suitably Linux-y shell with `wget`, `xmllint` and `jq`.
In its current state, keywords are hardcoded as regexes, and it does
two searches:

One for stations whose wiki summaries include keyword `music` and exclude
keywords `news`, `college`, `university`, `school`, and `classical`, with
output in `keywords/music-sans-boring.html`

And another for stations whose wiki summaries that include keywords `diverse`,
`diversity`, `mix`, `variety`, `alternative`, `cultural`, or `culture`, and
excluding keywords `news`, `college`, `university`, `school`, with output in
`keywords/variety-sans-boring.html`.

