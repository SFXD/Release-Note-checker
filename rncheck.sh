#!/usr/bin/env bash
year=`cat /home/user/rn-checker/year.dat`
seasonnum=`cat /home/user/rn-checker/seasonnum.dat`
seasons=(spring summer winter)
release=${seasons[$seasonnum]}$year
url=https://releasenotes.docs.salesforce.com/en-us/$release/release-notes/salesforce_release_notes.htm
rncode=`curl -s --head $url | head -n 1 | grep "HTTP/1.* 2\d*"`
base=`curl -s --head https://releasenotes.docs.salesforce.com/en-us/winter19/release-notes/salesforce_release_notes.htm | head -n 1 | grep "HTTP/1.* 2\d*"`
if [[ $rncode == $base ]]; then
        echo "Release Notes Preview are out at $url!" | mail -s "New Release Note Are Out!" youremail@mail.com
        if [[ $seasonnum == 1 ]]; then
                year=$((year+1))
        fi
        if [[ $seasonnum == 2 ]]; then
                seasonnum=0
        else
                seasonnum=$((seasonnum+1))
        fi
        echo "${year}" > /home/user/rn-checker/year.dat
        echo "${seasonnum}" > /home/user/rn-checker/seasonnum.dat
fi