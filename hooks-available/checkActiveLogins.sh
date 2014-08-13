#!/bin/bash
#
# @AUTHOR: Sven Burkard <dev@sven-burkard.de>
# @DESC..: quits with an exit code of 1, if a user is still logged in. 
########################################################################


XBMC_HOST='127.0.0.1'
XBMC_PORT='8080'
XBMC_USER='xbmc'
XBMC_PASSWORD='xbmc'



BIN_DIRNAME='/usr/bin/dirname'
BIN_WHO='/usr/bin/who'
BIN_WC='/usr/bin/wc'


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

if ! [[ -x $BIN_WHO ]]; then
  MSG="ERROR: $BIN_WHO can not be executed!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 0 
fi

if ! [[ -x $BIN_WC ]]; then
  MSG="ERROR: $BIN_WC can not be executed!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 0 
fi


RESULT=`$BIN_WHO -u | $BIN_WC -l`

if [ $RESULT -ne '0' ]; then
  MSG="there are still users logged in!!"

  echo $MSG
  $BIN_MSG $XBMC_HOST $XBMC_PORT $XBMC_USER $XBMC_PASSWORD "checkActiveLogins.sh:" "$MSG"
  exit 1
fi


exit 0

