#!/bin/bash
#
# @AUTHOR: Sven Burkard <dev@sven-burkard.de>
# @DESC..: quits with an exit code of 1, if vdr is recording right now or the next timer is close. 
####################################################################################################


XBMC_HOST='127.0.0.1'
XBMC_PORT='8080'
XBMC_USER='xbmc'
XBMC_PASSWORD='xbmc'


# if you wanna use this script with an vdr-server not running on localhost,
# you have to allow svdrp in your vdr settings (at least for the ip address of this xbmc client).
#
# 127.0.0.1 should be allowed by default

VDR_HOST='127.0.0.1'
VDR_PORT='6419'
MINUTES_TO_WAIT_FOR_NEXT_TIMER=15



SECONDS_TO_WAIT_FOR_NEXT_TIMER=$(( $MINUTES_TO_WAIT_FOR_NEXT_TIMER * 60 ))


BIN_DIRNAME='/usr/bin/dirname'
BIN_NETCAT='/bin/netcat'
BIN_AWK='/usr/bin/awk'
BIN_TR='/usr/bin/tr'
BIN_EGREP='/bin/egrep'


if ! [[ -x $BIN_DIRNAME ]]; then
  echo "ERROR: $BIN_DIRNAME can not be executed!"
  exit 0
fi


PATH_HOOKS_ENABLED=$($BIN_DIRNAME $0)
BIN_MSG=$PATH_HOOKS_ENABLED'/../bin/sendMSGtoXBMC'


if ! [[ -x $BIN_MSG ]]; then
  echo "ERROR: $BIN_MSG can not be executed!"
  exit 0
fi

if ! [[ -x $BIN_NETCAT ]]; then
  MSG="ERROR: $BIN_NETCAT can not be executed!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 1
fi

if ! [[ -x $BIN_AWK ]]; then
  echo ""
  MSG="ERROR: $BIN_AWK can not be executed!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 1
fi

if ! [[ -x $BIN_TR ]]; then
  MSG="ERROR: $BIN_TR can not be executed!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 1
fi

if ! [[ -x $BIN_EGREP ]]; then
  MSG="ERROR: $BIN_EGREP can not be executed!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 1
fi


SECONDS_UNTIL_NEXT_TIMER=`echo -e "NEXT rel\nQUIT" | $BIN_NETCAT $VDR_HOST $VDR_PORT | $BIN_AWK '/^250/ { print $3 }' | $BIN_TR -d '\r' | $BIN_EGREP '^-?[0-9]+$'`

if ! [ $SECONDS_UNTIL_NEXT_TIMER ]; then

  MSG="ERROR: the cmd for requesting the seconds until the next vdr timer starts, wasn't successfull."

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"

  exit 1

fi


if [ `echo $SECONDS_UNTIL_NEXT_TIMER | $BIN_EGREP '^-'` ]; then

  MSG="shutdown will be canceled, because vdr is recording right now."

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"

  exit 1

elif [ $SECONDS_UNTIL_NEXT_TIMER -lt $SECONDS_TO_WAIT_FOR_NEXT_TIMER ]; then

  MSG="shutdown will be canceled, because the next vdr timer is in $SECONDS_UNTIL_NEXT_TIMER seconds."

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"

  exit 1

else

  MSG="next vdr timer is in $SECONDS_UNTIL_NEXT_TIMER seconds. this takes too long to wait for it. maximum amount of seconds to wait for the next timer is $SECONDS_TO_WAIT_FOR_NEXT_TIMER"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"

  exit 0

fi

