#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

chown -R mflasquin:mflasquin $PROJECT_ROOT
chown -R mflasquin:mflasquin /home/mflasquin

#CHANGE UID IF NECESSARY
if [ ! -z "$MFLASQUIN_UID" ]
then
  echo "change mflasquin uuid"
  usermod -u $MFLASQUIN_UID mflasquin
fi

exec "$@"