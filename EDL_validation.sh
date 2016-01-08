#!/bin/bash

#hostls="cs81 cs83 cs86 cs87 eu0 eu1 eu2 eu3 eu4 eu6"
hostls="cs81"
services="app cbatch dapp acs mq search db ffx"
IFILE='EDL-frf-sp1-mandm_sp-frf-intrasite.dat'
TOOFILE='tooutput.txt'
FMOFILE='fmoutput.txt'
regex='ops0-mm shared1-log shared0-'

rmfile() {
   [ -f $1 ] && rm $1
}

rmfile $TOOFILE
rmfile $FMOFILE

checktopod() {

    echo "*** ${s} ***" >> $TOOFILE; 
    if [ "$s" == "app" ]; then
       ports="11211 32765 65535 8085 8800 8900 9319"
    elif [ "$s" == "cbatch" ]; then
       ports="32765 65535 8800 8900"
    elif [ "$s" == "dapp" ]; then
       ports="32765 65535 8001 8800 8900"
    elif [ "$s" == "acs" ]; then
       ports="22 32765 65535 80 8085 8800 8900" 
    elif [ "$s" == "mq" ]; then
       ports="32765 65535 443 5672 80 8800 8900 8999 9099"
    elif [ "$s" == "search" ]; then
       ports="32765 65535 8800 8900 8983"
    else
       return
    fi
    for p in $ports
    do
      for r in $regex
      do
        printf "%5d  %-10s\t" "$p" "$r" >> $TOOFILE
        # from ^ops0-mm|^shared1-log|^shared0- to destination c81 eg.
        egrep "^${r}" ${IFILE} | egrep "${h}\-${s}" | egrep $p | wc -l >> $TOOFILE
      done
    done
}

checkfmpod() {

    echo "*** ${s} ***" >> $FMOFILE; 
    if [ "$s" == "app" ]; then
       ports="6667 8000 10000 8080 8869 8889 9998"
    elif [ "$s" == "cbatch" ]; then
       ports="6667 8000 10000 8080 8869 8889 9998"
    elif [ "$s" == "dapp" ]; then
       ports="6667 8000 10000 8080 8869 8889 9998"
    elif [ "$s" == "acs" ]; then
       ports="6667 8000 10000 8080 8869 8889 9998"
    elif [ "$s" == "mq" ]; then
       ports="6667 8000 10000 8080 8869 8889 9998"
    elif [ "$s" == "search" ]; then
       ports="6667 8000 10000 8080 8869 8889 9998"
    else
       return
    fi
    for p in $ports
    do
      for r in $regex
      do
        printf "%5d  %-10s\t" "$p" "$r" >> $FMOFILE
        # from pod, eg cs81, to ops0-mm|shared1-log|shared0- destination
        egrep "^${h}\-${s}" ${IFILE} | egrep "${r}" | egrep $p | wc -l >> $FMOFILE
      done

    done
}

for h in $hostls
do
  echo "*** To $h ***" >> $TOOFILE
  echo "*** From $h ***" >> $FMOFILE

  for s in $services
  do
    checktopod $s
    checkfmpod $s
  done
  echo >> $TOOFILE
  echo >> $FMOFILE

done


