#!/bin/bash
#
# @AUTHOR: Sven Burkard <dev@sven-burkard.de>
# @DESC..: quits with an exit code of 1, if vdr is recording right now or the next timer is close. 
####################################################################################################


# if you wanna use this script with an vdr-server not running on localhost,
# you have to allow svdrp in your vdr settings (at least for the ip address of this xbmc client).
#
# 127.0.0.1 should be allowed by default


VDR_HOST='127.0.0.1'
VDR_PORT='6419'
MINUTES_TO_WAIT_FOR_NEXT_TIMER=15



BIN_NETCAT='/bin/netcat'
BIN_AWK='/usr/bin/awk'
BIN_TR='/usr/bin/tr'
BIN_EGREP='/bin/egrep'

SECONDS_TO_WAIT_FOR_NEXT_TIMER=$(( $MINUTES_TO_WAIT_FOR_NEXT_TIMER * 60 ))


if ! [[ -x $BIN_NETCAT ]]; then
  echo "ERROR: $BIN_NETCAT can not be executed!"
  exit 1
fi

if ! [[ -x $BIN_AWK ]]; then
  echo "ERROR: $BIN_AWK can not be executed!"
  exit 1
fi

if ! [[ -x $BIN_TR ]]; then
  echo "ERROR: $BIN_TR can not be executed!"
  exit 1
fi

if ! [[ -x $BIN_EGREP ]]; then
  echo "ERROR: $BIN_EGREP can not be executed!"
  exit 1
fi


SECONDS_UNTIL_NEXT_TIMER=`echo -e "NEXT rel\nQUIT" | $BIN_NETCAT $VDR_HOST $VDR_PORT | $BIN_AWK '/^250/ { print $3 }' | $BIN_TR -d '\r' | $BIN_EGREP '^-?[0-9]+$'`

if ! [ $SECONDS_UNTIL_NEXT_TIMER ]; then

  echo "ERROR: the cmd for requesting the seconds until the next vdr timer starts, wasn't successfull."
  exit 1

fi


if [ `echo $SECONDS_UNTIL_NEXT_TIMER | $BIN_EGREP '^-'` ]; then

  echo "shutdown will be canceled, because vdr is recording right now."
  exit 1

elif [ $SECONDS_UNTIL_NEXT_TIMER -lt $SECONDS_TO_WAIT_FOR_NEXT_TIMER ]; then

  echo "shutdown will be canceled, because the next vdr timer is in $SECONDS_UNTIL_NEXT_TIMER seconds."
  exit 1

else

  echo "next vdr timer is in $SECONDS_UNTIL_NEXT_TIMER seconds. this takes too long to wait for it. maximum amount of seconds to wait for the next timer is $SECONDS_TO_WAIT_FOR_NEXT_TIMER"
  exit 0

fi

