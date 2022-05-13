#!/bin/bash

SRC="/mnt/internal_ssl/*"
DEST="/mnt/persistent/internal-ssl"

mkdir -p $DEST

for f in $SRC
do
  filename=$(basename $f)
  if [[ ${filename} = certipy.json ]]; then
    cp $f ${DEST}/${filename}
  elif [[ ! ${filename} = *_trust.crt ]]; then
    dirname=${filename%%_*}
    mkdir -p ${DEST}/${dirname}
    filename=${filename##*_}
    cp $f ${DEST}/${dirname}/${filename}
  else
    cp $f ${DEST}/${filename}
  fi
done
