#!/bin/bash -ue

URL='ftp://isdcftp.gfz-potsdam.de/grace/Level-1B/GFZ/AOD'
REMOTE_LOC='RL06'
FILE_PREFIX=AOD1B
FILE_SUFFIX=X_06.asc.gz
YEAR_TODAY=$(date +%Y)
MONTH_TODAY=$(date +%m)
FILE_LIST=()
for y in $(seq 2013 $YEAR_TODAY)
do
  for m in $(seq -w 1 12)
  do
    [ $y -eq 2013 ] && [ $m -lt 12 ] && continue
    [ $y -eq $YEAR_TODAY ] && [ $m -ge $MONTH_TODAY ] && continue
    FILE_LIST+=($y/${FILE_PREFIX}_${y}-${m}-*_${FILE_SUFFIX})
  done
done

for i in ${FILE_LIST[@]}
do
  mkdir -p gz/$(dirname $i)
  lftp -e "mget $i -c -O gz/$(dirname $i); exit" $URL/$REMOTE_LOC
  for j in gz/$i
  do
    OUT=asc/$(dirname $i)/$(basename ${j%.gz})
    [ -d $(dirname $OUT) ] || mkdir -p $(dirname $OUT)
    [ -s $OUT ] || gunzip -c $j > $OUT
  done
done
