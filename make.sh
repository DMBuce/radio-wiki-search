#!/bin/bash

# work in whatever directory this script is in
cd "$(dirname "$0")"

# define some vars
head="<html><body><style>
	img { visibility:hidden; display:none; }
	td { vertical-align:top; }
</style>"
foot="</html></body>"
exclude='\b(news|college|university|school|classical)\b' 

# set up html files
echo "$head" > music.html
echo "$head" > variety.html
echo "$head" > volunteer.html

# do some searches
egrep -ih '\b(music)\b' data.html \
	| egrep -i '\b(npr|independent)\b' \
	| egrep -iv "$exclude" \
	>> music.html
egrep -ih '\b(divers(e|ity)|mix|variety|alternative|cultur(al|e))\b' data.html \
	| egrep -i '\b(npr|independent)\b' \
	| egrep -iv "$exclude" \
	>> variety.html
egrep -ih '\b(volunteer)\b' data.html \
	| egrep -iv "$exclude" \
	>> volunteer.html

# finish html files
echo "$foot" >> music.html
echo "$foot" >> variety.html
echo "$foot" >> volunteer.html

