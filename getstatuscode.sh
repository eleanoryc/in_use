#!/bin/bash

# this script will run curl command on a list of remote hosts.  statuscode.txt will have a list of hosts along with the status code of the curl command.  With converthtml.sh, it will generate a html file, sc_mmddyyyy.html
# ./getstatuscode.sh -i <inputfile_sp4> -x <PROXY> -u <URL>

usage() { echo "Usage: $0 [-i <inputfile>] [-x <PROXY>] [-u <URL>]" 1>&2; exit 1; }

removefile() {
  if [ -f $1 ]; then
    rm $1 2>/dev/null
  fi
}

gettime() {
  TSP_MSEC=`perl -MTime::HiRes -e 'print int(1000 * Time::HiRes::gettimeofday),"\n"'`
  echo $TSP_MSEC
}

while getopts ":i:x:u:" o; do
  case "${o}" in
    i)  #set option "i"
       i=${OPTARG}
       ;;
    x)  #set option "x"
       x=${OPTARG}
       ;;
    u)  #set option "u"
       u=${OPTARG}
       ;;
    *) usage
       ;;
  esac
done

if [ -z "${i}" ] || [ -z "${u}" ]; then
    usage
fi

kdestroy

kopt=20d
printf "Enter kerberos :"
kinit

PROXY=$x
URL=$u
CURLCMD="curl --connect-timeout \"30\" -s -o /dev/null -w \"%{http_code}\" -H \"X-TB-PARTNER-AUTH=123\" -X POST -x $PROXY $URL"

OUTPUTFILE=statuscode.txt
ERROR=error.txt

removefile $OUTPUTFILE
removefile $ERROR

for h in `cat $i`
do 
  echo $h
  unset BEGTIME ENDTIME RDTIME
  BEGTIME=$(gettime)
  echo -n "$h $u 443 https " >> $OUTPUTFILE 
  #ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $h "$CURLCMD" 1>>$OUTPUTFILE; echo "$h $?" >> $ERROR
  ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $h "$CURLCMD" 1>>$OUTPUTFILE; ret=$?; if [ $ret != 0 ]; then echo "$h $ret" >> $ERROR; fi

  #ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $h 'curl --connect-timeout \"30\" -s -o /dev/null -w \"%{http_code}\" -H \"X-TB-PARTNER-AUTH=123\" -X POST https://api.opentok.com" 1>> $OUTPUTFILE; (($? == 255)) && echo ' 2>>$ERROR


  ENDTIME=$(gettime)
  RDTIME=`echo "$ENDTIME - $BEGTIME" | bc`
  decTIME=`printf %.3f $(echo "$RDTIME/1000" | bc -l)`
  echo " $decTIME" >> $OUTPUTFILE


  if [ -f $ERROR ]; then
    if grep $h $ERROR>>/dev/null; then
      sed -e "/$h/d" $OUTPUTFILE > tempfile
      mv tempfile $OUTPUTFILE
    fi
  fi

done

./converthtml.sh
