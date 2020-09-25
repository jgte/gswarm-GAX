#!/bin/bash -ue


for i in "$@"
do
  case "$i" in
    zip)
      FLAGS=(--no-parent --no-clobber --no-directories --no-check-certificate)
      URL=http://icgem.gfz-potsdam.de/getseries/02_COST-G/Swarm
      ZIPFILE=Swarm.zip
      wget ${FLAGS[@]} $URL -O $ZIPFILE
      unzip $ZIPFILE
      rm -f $ZIPFILE
      exit
    ;;
    ftp)
      lftp -e "mirror --verbose=1 -c --no-recursion; exit" ftp://icgem.gfz-potsdam.de/02_COST-G/Swarm
      exit
    ;;
    *)
      echo "WARNING: ignoring input argument '$i'"
    ;;
  esac
done

#NOTICE: user in OSX need to install GNU date (gdate)
DATE=$(which gdate 2> /dev/null || which date)
if [ -z "$DATE" ]
then
  echo "ERROR: cannot find command 'date'"
  exit 3
fi
#need subdir to dump zip files
mkdir -p zipped

URL='https://swarm-diss.eo.esa.int/?do=download&'
REMOTE_LOC='file=swarm%2FLevel2longterm%2FEGF%2F'
FILE_SUFFIX=0101
FILE_PREFIX=SW_OPER_EGF_SHA_2_
YEAR_TODAY=$($DATE +%Y)
MONTH_TODAY=$($DATE +%m)
for y in $(seq 2013 $YEAR_TODAY)
do
  for m in $(seq -w 1 12)
  do
    [ $y -eq 2013 ] && [ $m -lt 12 ] && continue
    [ $y -eq $YEAR_TODAY ] && [ $m -ge $MONTH_TODAY ] && continue
    START=${y}${m}01T000000
    STOP=$($DATE --date="$y-$m-01 + 1 month -1 second" +%Y%m%dT%H%M%S)
    FILE=${FILE_PREFIX}_${START}_${STOP}_${FILE_SUFFIX}
    echo Downloading model from $y-$m: $FILE

    if ! wget --no-check-certificate --no-parent --no-directories --continue $URL$REMOTE_LOC$FILE.ZIP -O zipped/$FILE.ZIP
    then
      echo "ERROR: could not download file $FILE"
      exit 3
    fi
    unzip -o zipped/$FILE.ZIP
    rm -f $FILE.HDR
  done
done
#cleanup empty files in zipper dir
find zipped -empty -delete
