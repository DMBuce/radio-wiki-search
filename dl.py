#!/usr/bin/python

import requests
import sys
import os
from lxml import html

endpoint = 'https://en.wikipedia.org/w/api.php'
query = '?action=query&generator=transcludedin&titles=Template:Infobox%20radio%20station&prop=extracts&exintro&format=json'
url = 'https://en.wikipedia.org/api/rest_v1/page/html/%s'

r = requests.get(endpoint + query)
j = r.json()

while True:
#for k in range(15):
#for k in range(3):
    for i, page in j['query']['pages'].items():
        if page['title'].startswith("Template") or '/' in page['title']:
            continue

        os.makedirs(os.path.dirname('data/%s/%s.html'%(page['title'][:3],page['title'])), exist_ok=True)
        print(">> " + url % page['title'])
        response = requests.get(url % page['title'])
        with open('data/%s/%s.html'%(page['title'][:3],page['title']), 'w') as f:
            # get infobox
            tree = html.fromstring(response.content)
            infobox = tree.xpath('//table[@class="infobox vcard"]')

            # set some defaults
            name = page['title']
            city = "Unknown Location"
            site = '<a href="https://www.google.com/search?q=%s">Google Search</a>'%page['title']

            # search the infobox for some info
            names = infobox[0].xpath('//caption/text()')
            cities = infobox[0].xpath('//th[a/@title="City of license"]/following-sibling::td')
            areas = infobox[0].xpath('//th[text()="Broadcast area"]/following-sibling::td')
            streams = infobox[0].xpath('//th[a/@title="Webcast"]/following-sibling::td')
            websites = infobox[0].xpath('//th[text()="Website"]/following-sibling::td')

            # figure out name, city, site
            if len(names) > 0:
                name = names[0]

            if len(cities) > 0:
                city = cities[0].text_content()
            elif len(areas) > 0:
                city = areas[0].text_content()

            if len(streams) > 0:
                #site = '\n'.join('{}'.format(html.tostring(tag)) for tag in streams)
                site = html.tostring(streams[0], encoding='unicode')[4:-5]
            elif len(websites) > 0:
                site = html.tostring(websites[0], encoding='unicode')[4:-5]

            # write html to file
            #f.write("<style>.infobox {float: right; clear: right;}</style>\n")
            f.write("<!-- %s -->" % response.url)
            f.write("<table><tr><td style='vertical-align:top'>")
            f.write(page['extract'].replace("\n", " "))
            f.write("<b>URL:</b> ")
            f.write(site.replace("\n", " "))
            f.write(("<pre># %s (%s)</pre>"%(name, city)).replace("\n", " ").lower())
            f.write("</td><td>")
            f.write(html.tostring(infobox[0], encoding='unicode').replace("\n", " "))
            f.write("</td></tr></table>")
            f.write("<hr/>\n")

    if j['batchcomplete'] == "true":
        break

    r = requests.get(endpoint + query + ''.join('&{}={}'.format(key, value) for key, value in j['continue'].items()))
    j = r.json()

