#!/bin/bash

# This script will generate the definition file for Mail Split/Migration for ACL input generator
# ./split_mail.sh -t <type> -p <current pod> -d <dr site>
# Depends on the type of split, migration or s2m, user will be prompted to enter additional information for new pod/site

usage() { echo "Usage: $0 [-t <split|migration|s2m>] [-p current pod] [-d <dr site>]" 1>&2; exit 1; }

checksite() {
  if `echo $site | egrep -q "chi|dfw|lon|phx|was|tyo"` ; then
    value=false
    echo $value
  fi
}

promptsite() {
  value=true
  while $value
  do
    echo -n "Enter $sitenum site for type of split, chi|dfw|lon|phx|was|tyo: "
    read site
    value=$(checksite ${site})
    nsite=$site
    echo $nsite > /dev/null
  done
}

checkpod() {
  if `echo $pod| egrep -q "^na\d{1,2}$|^cs\d{1,2}$"` ; then
    value=false
    echo $value
  fi
}

promptpod() {
  value=true
  while $value
  do
    echo -n "Enter a valid $podnum pod, na29: "
    read pod
    value=$(checkpod ${pod})
    npod=$pod
    echo $npod > /dev/null
  done
}

HOSTFILE='./host_dictionary.txt'
DICTFILE=split_mail_def.dat
rm -rf $DICTFILE 2>/dev/null

createdeffile () {
# echo createfile $1 $2 $3 $4 $5 $6 $7 
 drsite=$1
 npod1=$2
 nsite1=$3
 npod2=$4
 nsite2=$5
 npod3=$6
 nsite3=$7
 CMP='cmp1-0'
 PORT='2525'
 PROTOCOL='tcp'

 SOURCE1='^ops[0-9]-mta[0-9]-[0-9]'
 #SOURCE2='^ops-mta[0-3][0–9]-[0-9]'
 SOURCE2='^ops-mta[0-3]*-[0-9]'
 DEST1=`egrep "$npod1-$CMP-$nsite1" $HOSTFILE` 
 DEST2=`egrep "$npod1-$CMP-$drsite" $HOSTFILE` 
echo $DEST1 $DEST2
 if [ ! -z $npod2 ] && [ ! -z $nsite2 ]; then
   DEST3=`egrep "$npod2-$CMP-$nsite2" $HOSTFILE`
   DEST4=`egrep "$npod2-$CMP-$drsite" $HOSTFILE`
 fi
 if [ ! -z $npod3 ] && [ ! -z $nsite3 ]; then
   DEST5=`egrep "$npod3-$CMP-$nsite3" $HOSTFILE`
   DEST6=`egrep "$npod3-$CMP-$drsite" $HOSTFILE`
 fi
 
 for mtahost1 in $SOURCE1 $SOURCE2; do
   echo "$mtahost1 $DEST1 $PROTOCOL $PORT" >> $DICTFILE
   echo "$mtahost1 $DEST2 $PROTOCOL $PORT" >> $DICTFILE
   if [ ! -z $npod2 ] && [ ! -z $nsite2 ]; then
     echo "$mtahost1 $DEST3 $PROTOCOL $PORT" >> $DICTFILE
     echo "$mtahost1 $DEST4 $PROTOCOL $PORT" >> $DICTFILE
   fi
   if [ ! -z $npod3 ] && [ ! -z $nsite3 ]; then
     echo "$mtahost1 $DEST5 $PROTOCOL $PORT" >> $DICTFILE
     echo "$mtahost1 $DEST6 $PROTOCOL $PORT" >> $DICTFILE
   fi
 done

 echo >> $DICTFILE

}

POD='eg. na29'
SITE='( chi|dfw|lon|phx|sjl|tyo|was )'
INPUTGENERATOR_SPT='ACL_Input_Generator.py'

OPTS=$(getopt -n "$0" -o tpd -l "type,curpod,drsite:" -- "$@")

if [ $# -eq 0 ] ; then usage >&2 ; exit 1 ; fi
if [ $? -ne 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "$OPTS"

while true; do
  case "$1" in
    -t|--type) shift; TYPE=$1; shift;;
    -p|--curpod) shift; CURPOD=$1; shift;;
    -d|--drsite) shift; DRSITE=$1; shift ;;
    --) shift; break ;;
    * ) break ;;
  esac
done

if [ "$TYPE" == "migration" ] || [ "$TYPE" == "m" ]; then
  echo "Migration is the type."
  sitenum='1st'
  promptsite $sitenum
  NEWSITE1=$nsite
  NEWPOD1=$CURPOD

  echo -n "Will the migration happen on more than 1 pod? (y or n) "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
     podnum='2nd'
     promptpod $podnum
     NEWPOD2=$npod

     sitenum='2nd'
     promptsite $sitenum
     NEWSITE2=$nsite
     createdeffile $DRSITE $NEWPOD1 $NEWSITE1 $NEWPOD2 $NEWSITE2
  else
     createdeffile $DRSITE $NEWPOD1 $NEWSITE1
  fi

elif [ "$TYPE" == "split" ] || [ "$TYPE" == "s" ]; then
  echo "Split is the type."

  podnum='1st'
  promptpod $podnum
  NEWPOD1=$npod

  sitenum='1st'
  promptsite $sitenum
  NEWSITE1=$nsite

  echo -n "Will the split happen in more than 1 pod? (y or n) "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
     podnum='2nd'
     promptpod $podenum
     NEWPOD2=$npod
     sitenum='2nd'
     promptsite $sitenum
     NEWSITE2=$nsite
     createdeffile $DRSITE $NEWPOD1 $NEWSITE1 $NEWPOD2 $NEWSITE2
  else
     createdeffile $DRSITE $NEWPOD1 $NEWSITE1
  fi

elif [ "$TYPE" == 's2m' ]; then
   echo "Split2 and Migration is the type."
   NEWPOD1=$CURPOD
   sitenum='1st'
   promptsite $sitenum
   NEWSITE1=$nsite

   podnum='2nd'
   promptpod $podnum
   NEWPOD2=$npod
   sitenum='2nd'
   promptsite $sitenum
   NEWSITE2=$nsite

   echo -n "Are there more pods for Split2 and Migration? (y or n) "
   read answer
   if echo "$answer" | grep -iq "^y" ;then
     podnum='3rd'
     promptpod $podnum
     NEWPOD3=$npod
     sitenum='3rd'
     promptsite $sitenum
     NEWSITE3=$nsite
     createdeffile $DRSITE $NEWPOD1 $NEWSITE1 $NEWPOD2 $NEWSITE2 $NEWPOD3 $NEWSITE3
   else
     createdeffile $DRSITE $NEWPOD1 $NEWSITE1 $NEWPOD2 $NEWSITE2 
   fi

else
  usage

fi


echo "run python $INPUTGENERATOR_SPT --acl_def_file=./$DICTFILE"
#python $INPUTGENERATOR_SPT --acl_def_file=./$DICTFILE

