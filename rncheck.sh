#!/usr/bin/env bash
year=`cat /rn-checker/year.dat`
seasonnum=`cat /rn-checker/seasonnum.dat`
seasons=(spring summer winter)
release=${seasons[$seasonnum]}$year
url="https://releasenotes.docs.salesforce.com/en-us/$release/release-notes/salesforce_release_notes.htm"
rncode=`curl -s --head $url | head -n 1 | grep "HTTP/1.* 2\d*"`
base=`curl -s --head https://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/salesforce_release_notes.htm | head -n 1 | grep "HTTP/1.* 2\d*"`
currentmonth=`date +%B`
currentdate=`date`
webhookurl="yourwebhookurl"
jsoncontent='{"embeds":[{"title": "Preview Release Notes are out!","color": 29951,"description": "The official SF preview release notes are out. Get to work, @Windyo!","fields": [{"name": "Timestamp","value": "'$currentdate'"},{"name": "Link:","value": "'$url'"}],"footer": {"icon_url": "https://cdn.discordapp.com/embed/avatars/0.png","text": "Aaaah, I love the smell of fresh releases in the morning."}}]}'
if [[ $rncode == $base ]]; then
        if [[($seasonnum == "2" && ($currentmonth="September" || $currentmonth="August")) || ($seasonnum == "0" && ($currentmonth="January" || $currentmonth="February"))  || ($seasonnum == "1" && ($currentmonth="April" || $currentmonth="May")) ]]; then
                curl -H "Content-Type: application/json" -X POST -d "$jsoncontent" $webhookurl
                year=$((year+1))
                fi
                if [[ $seasonnum == 2 ]]; then
                        seasonnum=0
                else
                        seasonnum=$((seasonnum+1))
                fi
                echo "${year}" > /rn-checker/year.dat
                echo "${seasonnum}" > /rn-checker/seasonnum.dat
        fi
fi
