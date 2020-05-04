#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/event.inc.sh

## sanity checks
exists_workdir && die "workdir exists"

## do prepare
prepare_workdir() {
    ##config apiservices
    mkdir -p $ETCDIR/luids || return $?
    cp $DATADIR/apiservices.json $ETCDIR/luids || return $?
    
    ##config eventproc
    mkdir -p $ETCDIR/luids/event/event.d || return $?
    mkdir -p $VARDIR/lib/luids/event || return $?
    cp $DATADIR/eventproc.toml $ETCDIR/luids/event || return $?
    cp $DATADIR/eventproc-forward.toml $ETCDIR/luids/event || return $?
    cp $DATADIR/stacks.json $ETCDIR/luids/event || return $?
    cp $DATADIR/stacks-forward.json $ETCDIR/luids/event || return $?
    cp $DATADIR/event.d/*.json $ETCDIR/luids/event/event.d || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_eventproc &>>$RUNDIR/pre.log || die "testing eventproc config"
dryrun_eventproc "forward" &>>$RUNDIR/pre.log || die "testing eventproc forward"
