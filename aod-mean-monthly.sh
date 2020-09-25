#!/bin/bash

DIR=$(cd $(dirname $BASH_SOURCE);pwd)

YEAR=$1
MONTH=$2

SOURCE_FILES=$(ls $DIR/AOD1B/asc/$YEAR/AOD1B_$YEAR-$MONTH*06.asc)

$DIR/aod-mean.awk $SOURCE_FILES