#!/bin/bash

HTMLFILE=sc_`date +"%m%d%Y"`.html

let INDEX=0
let failINDEX=0
cat << EOF > $HTMLFILE
<html><body>
<center><font size+=2><b> IMT Validation on LA pre-production result & report on date $tdate `date` </b></font></center><br>
<hr>
<table border=1>
  <tr><td><b>Index</b></td>
      <td><b>SrcHost</b></td>
      <td><b>DestHost</b></td>
      <td><b>Port#</b></td>
      <td><b>Protocol</b></td>
      <td><b>StatusCode</b></td>
      <td><b>RoundTripTime</b></td>
  </tr>
EOF

while read line
do
  let INDEX=INDEX+1
  #INDEX=`echo $line | awk '{ print $1 }'`
  SOURCE=`echo $line | awk '{ print $1 }'`
  DEST=`echo $line | awk '{ print $2 }'`
  PORT=`echo $line | awk '{ print $3 }'`
  PROTOCOL=`echo $line | awk '{ print $4 }'`
  CODE=`echo $line | awk '{ print $5 }'`
  #echo "code is $CODE"
  if [ -z "$CODE" ]; then
    STATUS='white'    
    CODE='connection error'
  
  elif [ $CODE -le 100 ]; then
       STATUS='yellow'
  elif [ $CODE -ge 400 ] && [ $CODE -lt 500 ]; then
       STATUS='yellow' 
  elif [ "$CODE" -ge 500 ]; then
       STATUS='red'
  else
       STATUS='green'
  fi

  TIME=`echo $line | awk '{ print $6 }'`

cat << EOF >> $HTMLFILE
  <tr><td>$INDEX</td>
      <td>$SOURCE</td>
      <td>$DEST</td>
      <td>$PORT</td>
      <td>$PROTOCOL</td>
      <td bgcolor=$STATUS>$CODE</td>
      <td>$TIME</td>
  </tr>
EOF

done<statuscode.txt

cat << EOF >> $HTMLFILE
</table>
<br><br>
EOF


if [ -f error.txt ]
then

cat << EOF >> $HTMLFILE
Problem hosts
<table border=1>
   <tr><td><b>Index</b></td>
       <td><b>SrcHost</b></td>
       <td><b>StatusCode</b></td>
       <td><b>RoundTripTime</b></td>
   </tr>
EOF

while read line
do
  SOURCE=`echo $line | awk '{ print $1 }'`
  ERROR=`echo $line | awk '{$1=""; print substr($0,2)}'`
  let failINDEX=failINDEX+1
cat << EOF >> $HTMLFILE
  <tr><td>$failINDEX</td>
      <td>$SOURCE</td>
      <td bgcolor=red>$ERROR</td>
      <td>000</td>
  </tr>

EOF
done<error.txt

fi

cat << EOF >> $HTMLFILE
</table>
<br><br>
</body></html>
EOF
