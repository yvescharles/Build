#!/bin/bash
clear
message='
-----------------------------------\n
- script de compilation auto PX4  -\n
-----------------------------------\n'
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
#git tag -l
#read -p 'Entrez le numéro de version à compiler (12 car  max) : ' -n 12 -t 25 nom
nom="v1.8.2"
#git checkout $nom
#git branch
#git status
#git pull origin $nom

nomcompil="compilation_$nom"
dir="~/root/Build/$nomcompil"
log="$dir/log.txt"
git checkout -b $nomcompil
mkdir -p $dir
git branch
sleep 5

cd ~/src/Firmware
sudo ./Tools/docker_run.sh 'make clean'
sudo ./Tools/docker_run.sh 'make px4_fmu-v3_default'
cp ~/src/Firmware/build/px4_fmu-v3_default/px4_fmu-v3_default.px4 $dir/px4_fmu-v3_default.px4

git branch
git status

