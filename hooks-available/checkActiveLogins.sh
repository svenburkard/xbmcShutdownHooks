#!/bin/bash
#
# @AUTHOR: Sven Burkard <dev@sven-burkard.de>
# @DESC..: quits with an exit code of 1, if a user is still logged in. 
########################################################################


BIN_WHO='/usr/bin/who'
BIN_WC='/usr/bin/wc'


if ! [[ -x $BIN_WHO ]]; then
  echo "ERROR: $BIN_WHO can not be executed!"
  exit 0 
fi

if ! [[ -x $BIN_WC ]]; then
  echo "ERROR: $BIN_WC can not be executed!"
  exit 0 
fi


RESULT=`$BIN_WHO -u | $BIN_WC -l`

if [ $RESULT -ne '0' ]; then
  exit 1
fi


exit 0

