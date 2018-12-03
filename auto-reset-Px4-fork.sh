#!/bin/bash
clear
daten=`date +%y%m%d-%H%M%S`
message="
----------------------------------------------------------------------------------\n
--     script de compilation auto PX4 v$daten  --\n
----------------------------------------------------------------------------------\n"
echo -e $message

nom="v_$daten"

nomcompil="compilation_$nom"
dir="/root/Build/$nomcompil"
log="$dir/log.txt"
cd /root/Buid
git checkout -b "$nomcompil"
mkdir -p $dir

cd /root/src/Firmware
sudo ./Tools/docker_run.sh 'make clean'
sudo ./Tools/docker_run.sh 'make px4_fmu-v3_default'
cp /root/src/Firmware/build/px4_fmu-v3_default/px4_fmu-v3_default.px4 $dir/px4_fmu-v3_default.px4

read -p 'Entrez le commentaire de cette version à commiter (12 car  max) : ' -n 12 -t 30  comm
cd $dir
git branch
git status
git add $dir
git commit -m "push auto $nom $comm"
git push origin $nomcompil
git checkout master

