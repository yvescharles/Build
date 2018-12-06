#!/bin/bash
#================================================================
#
# script de compilation automatique du firmware PX4
#
# by yc@avioneo.com
#
#================================================================

# Variabes locales
racine=/root/Build
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
read -p "voulez-vous réinitialiser le fork à l'identique des sources d'origine ? :(o/n)" -n1 -t5 rep
if [ $rep = "o" ]
then 
	echo ""
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
   	cd $Firmware
	echo ""
	echo "la branche existe --> OK pour compliation"
	echo ""
	echo ""
	read -p 'Entrez le commentaire de cette version à commiter (20 car max) : ' -n 20 -t 30  comm
	echo ">>>>>>>> OK !"
	git checkout $branche

	echo ""
	echo "mise à jour de la branche depuis le repository clone sur GitHub"
	git pull

	echo ""
	echo ">>> creation d'une branche temporarire pouur la compilation du code"
	git checkout -B temp

	#iExecution des script de compilation
	header $ddatenow
	echo ">>>>>> complilation du Firmware"
	sudo ./Tools/docker_run.sh 'make clean'
	sudo ./Tools/docker_run.sh 'make px4_fmu-v3_default'
	mess="OK well done si la sortie ressemble à :\n
	-- Build files have been written to: $Firmware/src/Firmware/build/px4_fmu-v3_default.px4\n
	[1014/1014] Creating $Firmware/build/px4_fmu-v4_default/px4_fmu-v3_default.px4\n"
	echo -e $mess
	read -p "appuyer une touche porr continuer" -n1 -t 60	

	# Enregistrement du Firmware et publication sur GitHub
	header $datenow
	cd $racine
	git checkout master
	git checkout -b "$nomcompil"
	mkdir $dir
	cp $Firmware/build/px4_fmu-v3_default/px4_fmu-v3_default.px4 $dir/px4_fmu-v3_default.px4
	echo ""
	echo "publication sur GitHub"
	git add $dir
	git commit -m "push auto $nom $comm"
	git push origin $nomcompil
	git checkout master
	echo ""
	contenu "du dossier compilé" "$dir"

	cd $Firmware
	git checkout master
	git branch -D temp
	contenu "du dossier d'origine" "$Firmware"
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
		echo ""
		read -p "voulez-vous d'abord voir la liste complète des branches non synchronisées ? (o/n)" -n 1 -t 4 rep
		echo ""
	        if [ $rep = 'o' ]
		then
			git branch -a
			echo ""
			read -p "une branche à tirer ? (o/n)" -n 1 -t 5 rep
			if [ $rep = 'o' ]
			then
				echo ""
				read -p "son nom ? : " -n 30 distb
				echo ""
				git checkout --track origin/$distb
				git status
				sleep 5
				git log
				git checkout master
			fi
			echo ""
			echo "aller hop on relance !"
			auto-compil-Px4.sh
		else
			echo ""
			echo "c'est parti mon kiki je relaanec"
			auto-compil-Px4.sh
		fi
		echo ">>>> OK à bientôt !"
		echo ""
		echo ">>>>>>>> ATTENTION : FIN DU SCRIPT SANS COMPILATION"
	fi
fi
echo ""
