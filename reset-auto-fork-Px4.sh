#!/bin/bash
clear
message='
------------------------------------\n
- script de rest auto du fork PX4  -\n
------------------------------------\n'
echo -e $message

cd ~/
rm -r ~/src
mkdir ~/src
sleep 1
cd ~/src/
git clone https://github.com/yvescharles/Firmware.git
cd ~/src/Firmware/
git remote add original https://github.com/PX4/Firmware.git
git remote -v
git fetch original
git checkout master
git reset --hard original/master
git push origin master --force
git branch
git status
