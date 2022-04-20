#!/bin/bash

#---------------------------------------------------------------------------------------------
#Fonction utilisée pour déterminer si le temps est conforme-----------------------------------
#---------------------------------------------------------------------------------------------

function exe_ou_pas {

time1=$1           #temps de tache
time2=$2           #temps actuellement
time_begin=$3      #temps à laquelle le programme commence à courir

date_comparer=$(($4-1))

#Si le format de temps de la tâche est '*' , on le fait

if [ "$time1" = "*" ]
then
   return 1
fi

#Si le format de temps de la tâche est un nombre entier compris entre 0 et 99 , on le fait

type1=$(echo $time1|grep '^[0-9][0-9]\?$')

if [ "$type1" != "" ]
then
   if [ $type1 -eq $time2 ]
   then
      return 1
   else
      return 0
   fi
fi

#Si le format de temps de la tâche est est un intervalle de temps connecteé par '-'
#on le fait

type2=$(echo $time1|grep '^[0-9][0-9]\?-[0-9][0-9]\?$')

if [ "$type2" != "" ]
then
   echo type2
   min=$(echo $type2|cut -f 1 -d '-')
   max=$(echo $type2|cut -f 2 -d '-')
   if [ $min -gt $max ]
   then
      temp=$min
      min=$max
      max=$temp
   fi
   if [ $time2 -le $max -a $time2 -ge $min ]
   then
      return 1
   else
      return 0
   fi
fi

#Si le format de temps de la tâche est est un série d’entiers séparés par ','
#on le fait

type3=$(echo $time1|grep '^[0-9][0-9]\?\(,[0-9][0-9]\?\)*$')

if [ "$type3" != "" ]
then
   echo type3
   fois=$(echo $type3|awk -F',' '{print NF}')
   i=1
   flag=0
   while [ $i -le $fois ]
   do
    c=$(echo $type3|cut -f $i -d ',')
    if [ $time2 -eq $c ]
    then
       flag=1
       break
    fi
    i=$((i+1))
   done
   if [ $flag -eq 1 ]
   then
      return 1
   else
      return 0
   fi
fi

#Si le format de temps de la tâche est dans une formation comme '1-12~4~5'
#on le fait

type4=$(echo $time1|grep '^[0-9][0-9]\?-[0-9][0-9]\?\(~[0-9][0-9]\?\)*$')

if [ "$type4" != "" ]
then
   echo type4
   foi=$(echo $type4|awk -F'~' '{print NF}')
   limite=$(echo $type4|cut -f 1 -d '~')
   min=$(echo $limite|cut -f 1 -d '-')
   max=$(echo $limite|cut -f 2 -d '-')
   if [ $min -gt $max ]
   then
      temp=$min
      min=$max
      max=$temp
   fi

   i=2
   flag=0
   while [ $i -le $foi ]
   do
    c=$(echo $type4|cut -f $i -d '~')
    if [ $time2 -le $max -a $time2 -ge $min ]
    then
       if [ $c -ne $time2 ]
       then
          flag=$((flag+1))
       fi
    fi
    i=$((i+1))
   done
   testt=$((foi-1))
   if [ $flag -eq $testt ]
   then
      return 1
   else
      return 0
   fi
fi

#Si le format de temps de la tâche est dans une formation comme '0-23/3'
#on le fait

type6=$(echo $time1|grep '^.*-.*/.*$')
if [ "$type6" != "" ]
then
   time_max=$(echo $type6|cut -f 2 -d "-"|cut -f 1 -d "/")
   time_min=$(echo $type6|cut -f 1 -d "-")
   if [ $time2 -le $time_max -a $time2 -ge $time_min ]
   then
      if [ $5 -eq 0 ]
      then
         return 0
      fi
      d=$(echo $type6|cut -f 2 -d "-"|cut -f 2 -d "/")
      declare -a tab=(4 60 24 30 12 7)
      time_passe=$((b+tab[$date_comparer]-c))
      time_passe=$((time_passe%$d))
      if [ $time_passe -eq 0 ]
      then
         return 1
      else
         return 0
      fi
   else
      return 0
   fi
fi

type5=$(echo $time1|grep '^.*/.*$')

if [ "$type5" != "" ]
then

   d=$(echo $type5|cut -f 2 -d '/')
   if [ $5 -eq 0 ]
   then
       return 0
   fi
   declare -a tab=(4 60 24 30 12 7)
   time_passe=$((b+tab[$date_comparer]-c))
   time_passe=$((time_passe%$d))
   if [ $time_passe -eq 0 ]
   then
      return 1
   else
      return 0
   fi
fi


}

#-----------------------------------------------------------------------------------------------------------
#fin de fonction--------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------



#la procédure principale
#on vérifie d’abord l’existence des documents /etc/tacheron et /etc/tacherontab

if [ ! -d /etc/tacheron -o ! -f /etc/tacherontab ]
then
   echo "Documents clés manquants"
   exit
fi

#on vérifie aussi l’existence des documents /etc/tacheron.allow et /etc/tacheron.deny
if [ ! -f /etc/tacheron.allow -o ! -f /etc/tacheron.deny ]
then
   echo "Liste des autorités manquantes"
   exit
fi

if [ ! -f /var/log/tacheron ]
then
   echo "log manquantes"
   exit
fi

#obtenir le temps de commercer
time_start=$(date +"%S %M %H %d %m %w"|awk '{printf("%d ",$1/15);print$2,$3,$4,$5,$6}')
#on utilise command while et sleep pour mise en œuvre de la fonction de tests réguliers

while true
do
user=$(whoami)

#verifier ce qui exécute le programme
#le root peut accomplir toutes les tâches dans /etc/tacheron
#mais d'autre utilisateur ne peut accomplir que sa propre tâche dans son propre dossier

if [ $user = "root" ]
then
    dir_list=$(ls /etc/tacheron)
    #echo $dir_list
    #Accès à l’heure actuelle
    time=$(date +"%S %M %H %d %m %w"|awk '{printf("%d ",$1/15);print$2,$3,$4,$5,$6}')
    meme_ou_pas=1
    if [ "$time" = "$time_start" ]
    then
       meme_ou_pas=0
    fi

    for d in $dir_list #boucle pour Parcourir l’ensemble du dossier
        do
        dir=$d
        list="/etc/tacheron/$dir"
               while read t
               do
               j=1
               flagg=0
               while [ $j -le 6 ]  #boucle pour verifier d'exécuter ou pas
                  do
                  a=$(echo "$t"|cut -f $j -d' ')
                  b=$(echo $time|cut -f $j -d ' ')
                  c=$(echo $time_start|cut -f $j -d ' ')
                  
                  exe_ou_pas "$a" "$b" "$c" $j $meme_ou_pas
                  if [ "$a" = "*" -o $? -eq 1  ]
                  then
                     flagg=$((flagg+1))
                  fi
                  j=$(( j + 1 ))
               done
               if [ $flagg -eq 6 ]
               then
                  echo "L’heure actuelle est $time"
                  echo -n "\""
                  echo "$t"|awk 'BEGIN{} {for(i=7;i<=NF;i++) printf $i" "} END{}'
                  mission=$(echo "$t"|awk '{for(i=7;i<=NF;i++) print $i" "}')
                  echo "\" is done "
                  echo "Les résultats de la mise en œuvre sont les suivants:"
                  $mission
                  echo "-------------------------------------------------------------------"
                  echo "time:$time  " >> /var/log/tacheron
                  echo "$t"|awk 'BEGIN{} {for(i=7;i<=NF;i++) printf $i" "} END{}' >> /var/log/tacheron
               fi
           done < $list
    done
else

    time=$(date +"%S %M %H %d %m %w"|awk '{printf("%d ",$1/15);print$2,$3,$4,$5,$6}')
    meme_ou_pas=1
    if [ "$time" = "$time_start" ]
    then
       meme_ou_pas=0
    fi
    key1=$(grep "$user" /etc/tacheron.allow)
    key2=$(grep "$user" /etc/tacheron.deny)

    if [ "$key1" != "" -a "$key2" = "" ]
    then
       if [ ! -f /etc/tacheron/tacherontab$user ]
       then
          touch /etc/tacheron/tacherontab$user
       fi

       if [ $? -ne 0 ]
       then
          echo "Pas de répertoire utilisateur"
          exit
       fi

       list="/etc/tacheron/tacherontab$user"
           while read t
           do
               tache=$t
               j=1
               flagg=0
               while [ $j -le 6 ]
               do
                  a=$(echo "$t"|cut -f $j -d' ')
                  b=$(echo $time|cut -f $j -d ' ')
                  c=$(echo $time_start|cut -f $j -d ' ')
                  exe_ou_pas "$a" "$b" "$c" $j $meme_ou_pas
                  if [ "$a" = "*" -o $? -eq 1  ]
                     then
                     flagg=$((flagg+1))
                  fi
                  j=$((j+1))
               done
               
               if [ $flagg -eq 6 ]
               then
                  echo "L’heure actuelle est $time"
                  echo -n "\""
                  echo "$t"|awk 'BEGIN{} {for(i=7;i<=NF;i++) printf $i" "} END{}'
                  mission=$(echo "$t"|awk '{for(i=7;i<=NF;i++) print $i" "}')
                  echo "\" is done"
                  echo "Les résultats de la mise en œuvre sont les suivants:"
                  $mission
                  echo "-------------------------------------------------------------------"
                  echo "time:$time  " >> /var/log/tacheron
                  echo "$t"|awk 'BEGIN{} {for(i=7;i<=NF;i++) printf $i" "} END{}' >> /var/log/tacheron
                
               fi
           done < $list

    else
       echo "L’utilisateur actuel n’a pas de droits"
    fi
fi

sleep 15
done
