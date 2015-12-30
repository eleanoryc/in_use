#!/bin/bash

# This script will generate the definition file for Split/Migration for ACL input generator
# ./split_new.sh -t <type> -p <current pod> -s <current site> -d <dr site> 
# Depends on the type of split, migration or s2m, user will be prompted to enter additional information for new pod/site

usage() { echo "Usage: $0 [-t <split|migration|s2m>] [-p <current pod>] [-s <current site>] [-d <dr site>]" 1>&2; exit 1; }

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
    echo -n "Please enter a valid site: (chi|dfw|frf|lon|phx|sjl|tyo)"
    read site
    value=$(checksite ${site})
    nsite=$site
    echo $nsite > /dev/null
  done
}

createdeffile () {
# echo createfile $1 $2 $3 $4 $5 $6 $7 $8 $9 
 cpod=$1
 csite=$2
 npod1=$3
 nsite1=$4
 drsite=$5
 npod2=$6
 nsite2=$7
 npod3=$8
 nsite3=$9
 domainname='ops.sfdc.net'
# variables for ACS
 ACS='acs[0-9]-[0-9]'
 ACS_PORT='22'
 PROTOCOL='tcp'
# variables for Search
 SEARCH='search[0-9]-[0-9]'
# SEARCH_PORT='8983'
# variables for hbase
 MNDS='mnds[0-9]-[0-9]'
 DNDS='dnds[0-9]-[0-9]'
# variables for release hosts
 REL_PORT='22'
# variables for DB ADG
 DB='db[0-9]-[0-9]'
 DGDB='dgdb[0-9]-[0-9]'
 SBDB='sbdb[0-9]-[0-9]'
# variables for FFX Data
 FFXDATA='ffx[0-9]-[0-9]'
 FFXDATA_PORT='22'
# variables for EXADATA
 EXADATA='xdb[0-9]-[0-9]'
 EXADATA_PORT=''

 # ACS Data Replication
 echo "$cpod-$ACS-$csite.$domainname $npod1-$ACS-$nsite1.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
 echo "$npod1-$ACS-$nsite1.$domainname $cpod-$ACS-$csite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
 echo "$cpod-$ACS-$csite.$domainname $npod1-$ACS-$drsite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
 echo "$npod1-$ACS-$drsite.$domainname $cpod-$ACS-$csite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
# if $6/$7 exists
 if [ ! -z "$nsite2" ] && [ ! -z "$npod2" ]; then
  echo "$cpod-$ACS-$csite.$domainname $npod2-$ACS-$nsite2.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
  echo "$npod2-$ACS-$nsite2.$domainname $cpod-$ACS-$csite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
  echo "$cpod-$ACS-$csite.$domainname $npod2-$ACS-$drsite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
  echo "$npod2-$ACS-$drsite.$domainname $cpod-$ACS-$csite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
 fi
 if [ ! -z "$nsite3" ] && [ ! -z "$npod3" ]; then
  echo "$cpod-$ACS-$csite.$domainname $npod3-$ACS-$nsite3.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
  echo "$npod3-$ACS-$nsite3.$domainname $cpod-$ACS-$csite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
  echo "$cpod-$ACS-$csite.$domainname $npod3-$ACS-$drsite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
  echo "$npod3-$ACS-$drsite.$domainname $cpod-$ACS-$csite.$domainname $PROTOCOL $ACS_PORT" >> $DICTFILE
 fi
 echo >> $DICTFILE

 # Solr Search Data Replication
 SEARCH_PORT=(22 8983)
 
 echo "$cpod-$SEARCH-$csite.$domainname $npod1-$SEARCH-$nsite1.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
 echo "$npod1-$SEARCH-$nsite1.$domainname $cpod-$SEARCH-$csite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
 echo "$cpod-$SEARCH-$csite.$domainname $npod1-$SEARCH-$drsite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
 echo "$npod1-$SEARCH-$drsite.$domainname $cpod-$SEARCH-$csite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
 if [ ! -z "$nsite2" ] && [ ! -z "$npod2" ]; then
  echo "$cpod-$SEARCH-$csite.$domainname $npod2-$SEARCH-$nsite2.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
  echo "$npod2-$SEARCH-$nsite2.$domainname $cpod-$SEARCH-$csite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
  echo "$cpod-$SEARCH-$csite.$domainname $npod2-$SEARCH-$drsite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
  echo "$npod2-$SEARCH-$drsite.$domainname $cpod-$SEARCH-$csite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
 fi
 if [ ! -z "$nsite3" ] && [ ! -z "$npod3" ]; then
  echo "$cpod-$SEARCH-$csite.$domainname $npod3-$SEARCH-$nsite3.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
  echo "$npod3-$SEARCH-$nsite3.$domainname $cpod-$SEARCH-$csite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
  echo "$cpod-$SEARCH-$csite.$domainname $npod3-$SEARCH-$drsite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
  echo "$npod3-$SEARCH-$drsite.$domainname $cpod-$SEARCH-$csite.$domainname $PROTOCOL {${SEARCH_PORT[0]},${SEARCH_PORT[1]}}" >> $DICTFILE
 fi

 echo >> $DICTFILE

 # HBase Data Replication
 #for (( i=1;i<=5;i++ )); do
 # HBASE_PORT=`echo $(($RANDOM$RANDOM$RANDOM%65535+1001))`
HBASE_PORT=()
for (( i=1;i<=5;i++ )); do
  x=`echo $(($RANDOM$RANDOM$RANDOM%65535+1001))`
  HBASE_PORT+=($x)
done

  echo "$cpod-$MNDS-$csite.$domainname $npod1-$MNDS-$nsite1.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$cpod-$DNDS-$csite.$domainname $npod1-$DNDS-$nsite1.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$npod1-$MNDS-$nsite1.$domainname $cpod-$MNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$npod1-$DNDS-$nsite1.$domainname $cpod-$DNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$cpod-$MNDS-$csite.$domainname $npod1-$MNDS-$drsite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$cpod-$DNDS-$csite.$domainname $npod1-$DNDS-$drsite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$npod1-$MNDS-$drsite.$domainname $cpod-$MNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  echo "$npod1-$DNDS-$drsite.$domainname $cpod-$DNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  if [ ! -z "$nsite2" ] && [ ! -z "$npod2" ]; then
    echo "$cpod-$MNDS-$csite.$domainname $npod2-$MNDS-$nsite2.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$cpod-$DNDS-$csite.$domainname $npod2-$DNDS-$nsite2.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod2-$MNDS-$nsite2.$domainname $cpod-$MNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod2-$DNDS-$nsite2.$domainname $cpod-$DNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$cpod-$MNDS-$csite.$domainname $npod2-$MNDS-$drsite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$cpod-$DNDS-$csite.$domainname $npod2-$DNDS-$drsite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod2-$MNDS-$drsite.$domainname $cpod-$MNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod2-$DNDS-$drsite.$domainname $cpod-$DNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  fi
  if [ ! -z "$nsite3" ] && [ ! -z "$npod3" ]; then
    echo "$cpod-$MNDS-$csite.$domainname $npod3-$MNDS-$nsite3.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$cpod-$DNDS-$csite.$domainname $npod3-$DNDS-$nsite3.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod3-$MNDS-$nsite3.$domainname $cpod-$MNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod3-$DNDS-$nsite3.$domainname $cpod-$DNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$cpod-$MNDS-$csite.$domainname $npod3-$MNDS-$drsite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$cpod-$DNDS-$csite.$domainname $npod3-$DNDS-$drsite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod3-$MNDS-$drsite.$domainname $cpod-$MNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
    echo "$npod3-$DNDS-$drsite.$domainname $cpod-$DNDS-$csite.$domainname $PROTOCOL {${HBASE_PORT[0]},${HBASE_PORT[1]},${HBASE_PORT[2]},${HBASE_PORT[3]},${HBASE_PORT[4]}}" >> $DICTFILE
  fi
# done
 echo >> $DICTFILE

 # Release hosts to DB hosts SSH
 echo "$cpod-$DB-$csite.$domainname $npod1-$DB-$nsite1.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 echo "$cpod-$DGDB-$csite.$domainname $npod1-$DGDB-$nsite1.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 echo "$cpod-$SBDB-$csite.$domainname $npod1-$SBDB-$nsite1.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 echo "$npod1-$DB-$nsite1.$domainname $cpod-$DB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 echo "$npod1-$DGDB-$nsite1.$domainname $cpod-$DGDB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 echo "$npod1-$SBDB-$nsite1.$domainname $cpod-$SBDB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 if [ ! -z "$nsite2" ] && [ ! -z "$npod2" ]; then
  echo "$cpod-$DB-$csite.$domainname $npod2-$DB-$nsite2.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$cpod-$DGDB-$csite.$domainname $npod2-$DGDB-$nsite2.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$cpod-$SBDB-$csite.$domainname $npod2-$SBDB-$nsite2.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$npod2-$DB-$nsite2.$domainname $cpod-$DB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$npod2-$DGDB-$nsite2.$domainname $cpod-$DGDB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$npod2-$SBDB-$nsite2.$domainname $cpod-$SBDB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 fi
 if [ ! -z "$nsite3" ] && [ ! -z "$npod3" ]; then
  echo "$cpod-$DB-$csite.$domainname $npod3-$DB-$nsite3.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$cpod-$DGDB-$csite.$domainname $npod3-$DGDB-$nsite3.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$cpod-$SBDB-$csite.$domainname $npod3-$SBDB-$nsite3.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$npod3-$DB-$nsite3.$domainname $cpod-$DB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$npod3-$DGDB-$nsite3.$domainname $cpod-$DGDB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
  echo "$npod3-$SBDB-$nsite3.$domainname $cpod-$SBDB-$csite.$domainname $PROTOCOL $REL_PORT" >> $DICTFILE
 fi
 echo >> $DICTFILE

 # DB ADG Replication
 DBADG_PORT=( 1521 2115 )
   echo "$cpod-$DB-$csite.$domainname $npod1-$DB-$nsite1.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   echo "$cpod-$DGDB-$csite.$domainname $npod1-$DGDB-$nsite1.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   echo "$cpod-$SBDB-$csite.$domainname $npod1-$SBDB-$nsite1.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   echo "$npod1-$DB-$nsite1.$domainname $cpod-$DB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   echo "$npod1-$DGDB-$nsite1.$domainname $cpod-$DGDB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   echo "$npod1-$SBDB-$nsite1.$domainname $cpod-$SBDB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   if [ ! -z "$nsite2" ] && [ ! -z "$npod2" ]; then
     echo "$cpod-$DB-$csite.$domainname $npod2-$DB-$nsite2.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$cpod-$DGDB-$csite.$domainname $npod2-$DGDB-$nsite2.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$cpod-$SBDB-$csite.$domainname $npod2-$SBDB-$nsite2.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$npod2-$DB-$nsite2.$domainname $cpod-$DB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$npod2-$DGDB-$nsite2.$domainname $cpod-$DGDB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$npod2-$SBDB-$nsite2.$domainname $cpod-$SBDB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   fi
   if [ ! -z "$nsite3" ] && [ ! -z "$npod3" ]; then
     echo "$cpod-$DB-$csite.$domainname $npod3-$DB-$nsite3.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$cpod-$DGDB-$csite.$domainname $npod3-$DGDB-$nsite3.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$cpod-$SBDB-$csite.$domainname $npod3-$SBDB-$nsite3.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$npod3-$DB-$nsite2.$domainname $cpod-$DB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$npod3-$DGDB-$nsite2.$domainname $cpod-$DGDB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
     echo "$npod3-$SBDB-$nsite2.$domainname $cpod-$SBDB-$csite.$domainname $PROTOCOL {${DBADG_PORT[0]},${DBADG_PORT[1]}}" >> $DICTFILE
   fi
 #done
 echo >> $DICTFILE

 # FFX Data Replication
 echo "$cpod-$FFXDATA-$csite.$domainname $npod1-$FFXDATA-$nsite1.$domainname $PROTOCOL $FFXDATA_PORT" >> $DICTFILE
 echo "$npod1-$FFXDATA-$nsite1.$domainname $cpod-$FFXDATA-$csite.$domainname $PROTOCOL $FFXDATA_PORT" >> $DICTFILE
 if [ ! -z "$nsite2" ] && [ ! -z "$npod2" ]; then
  echo "$cpod-$FFXDATA-$csite.$domainname $npod2-$FFXDATA-$nsite2.$domainname $PROTOCOL $FFXDATA_PORT" >> $DICTFILE
  echo "$npod2-$FFXDATA-$nsite2.$domainname $cpod-$FFXDATA-$csite.$domainname $PROTOCOL $FFXDATA_PORT" >> $DICTFILE
 fi
 if [ ! -z "$nsite3" ] && [ ! -z "$npod3" ]; then
  echo "$cpod-$FFXDATA-$csite.$domainname $npod3-$FFXDATA-$nsite3.$domainname $PROTOCOL $FFXDATA_PORT" >> $DICTFILE
  echo "$npod3-$FFXDATA-$nsite3.$domainname $cpod-$FFXDATA-$csite.$domainname $PROTOCOL $FFXDATA_PORT" >> $DICTFILE
 fi
}

# end of all functions

# start

DICTFILE=split_def.dat
rm -rf $DICTFILE 2>/dev/null
INPUTGENERATOR_SPT='./connectivity_checker.py'

SITE='(chi|dfw|lon|phx|sil|tyo|was)'
#SITE=( chi dfw lon phx sil tyo was )
POD='(eg. na29)'

#OPTS=$(getopt -n "$0" -o tpsnmd -l "type,curpod,cursite,newpod1,newsite1,drsite:" -- "$@")
OPTS=$(getopt -n "$0" -o tpsd -l "type,curpod,cursite,drsite:" -- "$@")

if [ $# -eq 0 ] ; then usage >&2 ; exit 1 ; fi
if [ $? -ne 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
 
echo "$OPTS"
 
while true; do
  case "$1" in
    -t|--type) shift; TYPE=$1; shift;;
    -p|--curpod) shift; CURPOD=$1; shift ;;
    -s|--cursite) shift; CURSITE=$1; shift ;;
    -d|--drsite) shift; DRSITE=$1; shift ;;
    -h|--help) usage;;
    --) shift; break ;;
    * ) break ;;
  esac
done

#echo $TYPE $CURPOD $CURSITE $DRSITE

if [ "$TYPE" == "migration" ] || [ "$TYPE" == "m" ]; then
  echo "Migration is the type."
  echo -n "Where is the new site going to be, $SITE ? "
  read NEWSITE1
#  promptsite
#  NEWSITE1=$nsite
  NEWPOD1=$CURPOD
  echo -n "Will the migration happen on more than 1 pod? (y or n) "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
   echo -n "please enter the 2nd pod for migration, $POD ? "
   read NEWPOD2
   echo -n "please enter the 2nd site for migration, $SITE ? "
   read NEWSITE2
#   promptsite
#   NEWSITE2=$nsite
   createdeffile $CURPOD $CURSITE $NEWPOD1 $NEWSITE1 $DRSITE $NEWPOD2 $NEWSITE2
  else
   createdeffile $CURPOD $CURSITE $NEWPOD1 $NEWSITE1 $DRSITE
   #exit
  fi

elif [ "$TYPE" == "split" ] || [ "$TYPE" == "s" ]; then
  echo "Split is the type."
  echo -n "please enter the 1st pod for $TYPE, $POD ? "
  read NEWPOD1
  echo -n "please enter the 1st site for $TYPE, $SITE ? "
  read NEWSITE1
#  promptsite
#  NEWSITE1=$nsite

  echo -n "Will the split happen in more than 1 pod? (y or n) "
  read answer

  if echo "$answer" | grep -iq "^y" ;then
   echo -n "please enter the 2nd pod for $TYPE, $POD ? "
   read NEWPOD2
   echo -n "please enter the 2nd site for $TYPE, $SITE ? "
   read NEWSITE2
#   promptsite
#   NEWSITE2=$nsite
   createdeffile $CURPOD $CURSITE $NEWPOD1 $NEWSITE1 $DRSITE $NEWPOD2 $NEWSITE2 
   else
   createdeffile $CURPOD $CURSITE $NEWPOD1 $NEWSITE1 $DRSITE
   #exit
  fi

elif [ "$TYPE" == 's2m' ]; then
   echo "Split2 and Migration is the type."
  # echo -n "please enter 1st s2m pod. "
  # read NEWPOD1
   NEWPOD1=$CURPOD
   echo -n "please enter the 1st site for s2m, $SITE ? "
   read NEWSITE1
#   promptsite
#   NEWSITE1=$nsite
   echo -n "please enter the 2nd pod for s2m, $POD ? "
   read NEWPOD2
   echo -n "please enter the 2nd site for s2m, $SITE ? "
   read NEWSITE2
#   promptsite
#   NEWSITE2=$nsite
   echo -n "please enter the 3rd pod for s2m, $POD ? "
   read NEWPOD3
   echo -n "please enter the 3rd site for s2m, $SITE ? "
   read NEWSITE3
#   promptsite
#   NEWSITE3=$nsite
   createdeffile $CURPOD $CURSITE $NEWPOD1 $NEWSITE1 $DRSITE $NEWPOD2 $NEWSITE2 $NEWPOD3 $NEWSITE3
else
  echo -n "You have input $TYPE type. "
  echo "Please enter one of these types: split, migration, or s2m"
  usage
#  exit
fi



echo "python $INPUTGENERATOR_SPT --acl_def_file=./$DICTFILE"
