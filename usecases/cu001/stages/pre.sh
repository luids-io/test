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
    mkdir -p $ETCDIR/luids/xlist || return $?
    mkdir -p $VARDIR/lib/luids/xlist || return $?
    cp $DATADIR/xlistd.toml $ETCDIR/luids/xlist || return $?
    cp $DATADIR/services.json $ETCDIR/luids/xlist || return $?
    cp $DATADIR/*.xlist $VARDIR/lib/luids/xlist || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_xlistd &>$RUNDIR/pre.log || die "testing xlistd config"
