#!/bin/bash
#================================================================
#
# script de compilation automatique du firmware PX4
#
# by yc@avioneo.com
#
#================================================================

# Variabes locales
racine=`pwd`
Firmware="/root/src/Firmware"
datenow=`date +%y%m%d-%H%M%S`
nom="v_$datenow"
nomcompil="compilation_$nom"
dir="$racine/$nomcompil"
log="$dir/log.txt"

# Update varaible globale rep en cours
PATH="$PATH:$racine"

# fonction header
header(){
local message="\n
----------------------------------------------------\n
--     script de compilation auto PX4 v_$1   --\n
----------------------------------------------------\n"
# impression UI
clear
echo -e $message
}


# START : Initialisation choix reset fork
header $datenox
read -p "voulez-vous réinitialiser le fork à l'identique des sources d'origine ? :(o/n)" -n1 -t1 rep
if [ rep = "o" ]
then 
	echo "Ok réinitialisation dans 5sec"
	sleep 5
	reset-auto-fork-Px4.sh
fi

# refresh screen now
header $datenow

# Préparation compilation
contenu(){
cd $2
echo ""
echo "contenu du dossier $1 $2"
ls
echo ""
git status
echo ""
echo "liste des branches dans le repository :"
git branch 
sleep 2
}

contenu "de destination " "$racine"
header $datenow
contenu "source clone de PX4/Firmware :" "$Firmware" 

#Selection et Test de la Branche à compiler
echo ""
echo "Ctrl+C pour abort si vous avez vu du rouge !"
echo ""
read -p 'Entrez le nom de la branche du Firmware à compiler (30sec / 15 car max) : ' -n 15 -t 30  branche

exists=`git show-ref refs/heads/$branche`
if [ -n "$exists" ]
then
   	echo ""
	echo "la branche existe --> OK pour compliation"
	echo ""
	read -p 'Entrez le commentaire de cette version à commiter (20 car max) : ' -n 20 -t 30  comm
	echo ">>>>>>>> OK !"
	git checkout $branche
	git branch
	echo ""
	echo "creation d'une branche temporarire pouur la compilatio du code"
	git checkout -B temp
	

	#iExecution des script de compilation
	sudo ./Tools/docker_run.sh 'make clean'
	sudo ./Tools/docker_run.sh 'make px4_fmu-v3_default'

	# Enregistrement du Firmware et publication sur GitHub
	cd $racine
	git checkout -b "$nomcompil"
	mkdir -p $dir
	cp $Firmware/build/px4_fmu-v3_default/px4_fmu-v3_default.px4 $dir/px4_fmu-v3_default.px4
	
	contenu "di dossier compilé" "$dir"
	
	echo "publication sur GiHub"
	git add $dir
	git commit -m "push auto $nom $comm"
	git push origin $nomcompil

	git checkout master
	git branch -D temp
	echo ""
	echo "FIN DU SCRIPT NORMALE"
else
	echo ""
	echo ">>>>>>> ATTENTION ! cette branche n'existe pas --> STOP"
	echo ""
	read -p "réessayer ? (o/n) : " -n 1 -t 30 rep
	echo ""
	if [ $rep = 'o' ]
	then
		echo "allez hop on y va !"
		auto-compil-Px4.sh
	else
		echo ">>>> OK à bientôt !"
		echo ""
		echo ">>>>>>>> ATTENTION : FIN DU SCRIPT SANS COMPILATION"
	fi
fi
echo ""
