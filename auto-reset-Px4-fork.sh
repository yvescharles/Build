#!/bin/bash
clear
daten=`date +%y%m%d-%H:%M:%S`
message="
----------------------------------------------------------------------------------\n
--     script de compilation auto PX4 v$daten  --\n
----------------------------------------------------------------------------------\n"
echo -e $message

nom="v_$daten"

nomcompil="compilation_$nom"
dir="/root/Build/$nomcompil"
log="$dir/log.txt"
git branch -D $nomcompil
git checkout -b $nomcompil
mkdir -p $dir

cd /root/src/Firmware
#sudo ./Tools/docker_run.sh 'make clean'
#sudo ./Tools/docker_run.sh 'make px4_fmu-v3_default'
cp /root/src/Firmware/build/px4_fmu-v3_default/px4_fmu-v3_default.px4 $dir/px4_fmu-v3_default.px4

cd $dir
git branch
git status
git add $dir
git commit -m "push auto $nom"
git push origin $nomcompil

