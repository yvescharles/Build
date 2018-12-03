#!/bin/bash
PATH="$PATH:`pwd`"
echo $PATH

# Chargement de l'entête
header-compil.sh

# Préparation compilation
cd /root/src/Firmware
echo ""
echo "Contenu du dossier source clone de PX4/Firmware :"
ls

echo""
git status

echo ""
echo "liste des branches dans le repository :"
git branch

# Selection et Test de la Branche à compiler
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
	compil-Px4.sh
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
