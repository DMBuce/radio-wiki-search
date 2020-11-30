#!/bin/bash

# work in whatever directory this script is in
cd "$(dirname "$0")"

# set up some folders
mkdir -p stations keywords

# pull down wiki pages
[[ -f List_of_NPR_stations ]] \
	|| wget 'https://en.wikipedia.org/wiki/List_of_NPR_stations'
[[ -f List_of_independent_radio_stations ]] \
	|| wget 'https://en.wikipedia.org/wiki/List_of_independent_radio_stations'
sed -i '/"Special:Search">/ s,>$,/>,' List_of_*

# parse them out
# columns: radio frequency, station code, wiki summary url
xmllint --xpath '//tr/td[2]/a | //tr/td[3]/text()' List_of_NPR_stations \
	| egrep '[A-Z]{3,4}|^[0-9].*[AF]M$' \
	| paste -d " "  - - \
	| sed -r '
		s@.*(/wiki/[^"]*).*>([A-Z-]{3,})</a> (.*)@\3 \2 \1@
		s,/wiki/,https://en.wikipedia.org/api/rest_v1/page/summary/,
		s/ (.M)/\1/
	' > List_of_NPR_stations.dat
xmllint --xpath '//ul/li' List_of_independent_radio_stations \
	| sed -nr '
		/[A-Z]{3,}/ {
			s@.*href="(/wiki/[^"]*)".*>([A-Z-]{3,})</a>[^0-9.]*([FA]M\s*[0-9.]+|[0-9.]+\s*[FA]M).*@\3 \2 \1@
			s,/wiki/,https://en.wikipedia.org/api/rest_v1/page/summary/,
			s,([FA]M)\s*([0-9.]+),\2\1,
			s,([0-9.]+)\s*([FA]M),\1\2,
			/^[0-9]/p
		}
	' > List_of_independent_radio_stations.dat

# the list of npr stations will go from 884 to 882 in the next step
# this is because of the following two duplicates on the wiki page:
#
# 89.3FM KPCC
# 89.9FM KCRW
#
# also, the independent stations that don't have wiki pages get lost here
# we can't do anything useful with those stations anyway, so no worries

# grab the summary for each station
while read freq station url; do
	[[ -f "stations/$freq-$station.html" ]] && continue
	wget -O "stations/$freq-$station.html" "$url" || echo $station >> errors.out
	sleep 0.2
done < <(cat List_of_*.dat) &>wget.out
#done < List_of_NPR_stations.dat &>wget.out
#done < List_of_independent_radio_stations.dat &>wget.out

# search for keywords in wiki summaries
egrep -i -l '\bmusic\b' stations/*.html | sort > keywords/music.dat
egrep -i -l '\b(diverse|diversity|mix|variety|alternative|cultural|culture)\b' stations/*.html | sort > keywords/variety.dat
#egrep -i -l '\bnews\b' stations/*.html | sort > keywords/news.dat
#egrep -i -l '\b(college|university)\b' stations/*.html | sort > keywords/college.dat
#comm -12 keywords/{news,music}.dat > keywords/both.dat
#grep -v -Ff <(cat keywords/{news,music}.dat | sort -u) <(printf "%s\n" stations/*.html) | sort > keywords/neither.dat
#grep -v -Ff keywords/news.dat keywords/music.dat > keywords/music-only.dat
#grep -v -Ff keywords/college.dat keywords/music-only.dat > keywords/music-only-sans-college.dat

# convert to something resembling html
for i in keywords/*.dat; do
#[[ ! -f keywords/music.html ]] && for i in keywords/music.dat; do
#[[ ! -f keywords/variety.html ]] && for i in keywords/variety.dat; do
	for file in $(< "$i" ); do
		jq '.extract_html' < "$file"
	done \
	| sed 's/^"//; s/"$//; s/\\"/"/g' > "${i%.dat}.html"
done

# filter out other keywords
egrep -i -v '\b(news|college|university|school|classical)\b' keywords/music.html | awk '!x[$0]++' > keywords/music-sans-boring.html
egrep -i -v '\b(news|college|university|school)\b' keywords/variety.html | awk '!x[$0]++' > keywords/variety-sans-boring.html

