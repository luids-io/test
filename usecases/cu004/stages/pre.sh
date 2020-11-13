#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh

## sanity checks
exists_workdir && die "workdir exists"

## do prepare
prepare_workdir() {
    mkdir -p $ETCDIR/luids/xlist/sources.d || return $?
    mkdir -p $VARDIR/cache/luids/xlist || return $?
    mkdir -p $VARDIR/lib/luids/xlist || return $?
    mkdir -p $VARDIR/lib/luids/xlist/status || return $?
    cp $DATADIR/xlget.toml $ETCDIR/luids/xlist || return $?
    cp $DATADIR/*.json $ETCDIR/luids/xlist/sources.d || return $?
}


create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_xlget &>>$RUNDIR/pre.log || die "testing xlget config"
