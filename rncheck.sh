#!/usr/bin/env bash

# variable declaration
year=`cat /home/windyo/docker/rn-checker/year.dat`
seasonnum=`cat /home/windyo/docker/rn-checker/seasonnum.dat`
lastpreview=`cat /home/windyo/docker/rn-checker/lastpreview.dat`
seasons=(spring summer winter)
release=${seasons[$seasonnum]}$year
url=https://releasenotes.docs.salesforce.com/en-us/$release/release-notes/salesforce_release_notes.htm
previewurl=https://www.salesforce.com/form/signup/prerelease-$release/
rncode=`curl -s -o /dev/null -w "%{http_code}" $url`
base=`curl -s -o /dev/null -w "%{http_code}" https://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/salesforce_release_notes.htm`
currentmonth=`date +%B`
currentdate=`date`
jsoncontent='{"content": "Tagging: <@&703592126608572436>, you requested to be notified about these.","embeds":[{"title": "Preview Release Notes are out!","color": 29951,"description": "The official SF preview release notes are out.\r Get to work, <@224942536043659264>! \r\r You can read the full release notes by following the link below.","fields": [{"name": "Timestamp","value": "'$currentdate'"},{"name": "Link","value": "'$url'"},{"name": "Subscription","value": "Get notified about these events by doing `?rank sfxd:notify:releasenotes` in <#337736985676480515>"}],"footer": {"icon_url": "https://cdn.discordapp.com/embed/avatars/0.png","text": "Aaaah, I love the smell of fresh releases in the morning."}}]}'
previewjsoncontent='{"content": "Tagging: <@&703592127283855441>, you requested to be notified about these.","embeds":[{"title": "Pre-Release Organization Signups are available!","color": 29951,"description": "Salesforce has made the pre-release organizations available for '$release'.\r Follow the link to play with preview features!","fields": [{"name": "Timestamp","value": "'$currentdate'"},{"name": "Link","value": "'$previewurl'"},{"name": "Subscription","value": "Get notified about these events by doing `?rank sfxd:notify:prereleaseorgs` in <#337736985676480515>"}],"footer": {"icon_url": "https://cdn.discordapp.com/embed/avatars/0.png","text": "Remember that this is a preview of a preview, expect broken stuff."}}]}'
webhookurl=""

# sanity checks for manual review
# echo "rncode: $rncode"
# echo "seasonnum: $seasonnum"
# echo "release: $release"
# echo "year: $year"
# echo "currentmonth: $currentmonth"

# testing grounds
# test release notes json
# curl -H "Content-Type: application/json" -X POST -d "$jsoncontent" $webhookurl
# test preview org json
# curl -H "Content-Type: application/json" -X POST -d "$previewjsoncontent" $webhookurl

# check for release notes
if [[ $rncode == $base && $base != 4* && $base != 3* && ($rncode == 2* || $rncode == 3*) ]]; then
        if [[($seasonnum == "2" && ($currentmonth == "September" || $currentmonth == "August")) || ($seasonnum == "0" && ($currentmonth == "December" || $currentmonth == "January"))  || ($seasonnum == "1" && ($currentmonth == "April" || $currentmonth == "May" || $currentmonth == "June" || $currentmonth == "July")) ]]; then
                echo "Release Notes Preview are out at $url!" | mail -s "New Release Note Are Out!" w_i_n_d_y_o@hotmail.com
                curl -H "Content-Type: application/json" -X POST -d "$jsoncontent" $webhookurl
                if [[ $seasonnum == 1 ]]; then
                        year=$((year+1))
                fi
                if [[ $seasonnum == 2 ]]; then
                        seasonnum=0
                else
                        seasonnum=$((seasonnum+1))
                fi
                echo "${year}" > /home/windyo/docker/rn-checker/year.dat
                echo "${seasonnum}" > /home/windyo/docker/rn-checker/seasonnum.dat
        fi
fi

# check for preview Subscription URLs
if [[ $lastpreview != $release ]]; then
        previewcode=`curl -s -o /dev/null -w "%{http_code}" $previewurl`
        if [[ $previewcode != 4* && $previewcode != 3* ]]; then
                curl -H "Content-Type: application/json" -X POST -d "$previewjsoncontent" $webhookurl
                echo "${release}" > /home/windyo/docker/rn-checker/lastpreview.dat
        fi
fi
