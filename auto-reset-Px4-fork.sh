#!/bin/bash
clear
message='
-----------------------------------\n
- script de compilation auto PX4  -\n
-----------------------------------\n'
echo -e $message


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

