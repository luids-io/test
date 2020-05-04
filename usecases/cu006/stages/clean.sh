#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/archive.inc.sh
. $BASEDIR/lib/luids/event.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_luarchive && die "luarchive is running"
running_eventproc && die "eventproc is running"

## drop database
$MONGOCLI --quiet $USECASE --eval "db.dropDatabase()" &>$RUNDIR/clean.log
[ $? -eq 0 ] || die "drop database $USECASE_ID"

## do clean
clean_workdir
