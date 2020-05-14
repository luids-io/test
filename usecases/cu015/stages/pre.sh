#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/archive.inc.sh

## sanity checks
exists_workdir && die "workdir exists"
check_mongo || die "can't contact mongodb"

## do prepare
prepare_workdir() {
    ##config apiservices
    mkdir -p $ETCDIR/luids || return $?
    
    ##config luarchive
    mkdir -p $ETCDIR/luids/archive || return $?
    cp $DATADIR/luarchive.toml $ETCDIR/luids/archive || return $?
    cp $DATADIR/backends.json $ETCDIR/luids/archive || return $?
    cp $DATADIR/services.json $ETCDIR/luids/archive || return $?
    
    ##config cap files
    cp $DATADIR/*.cap $TMPDIR || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_luarchive &>$RUNDIR/pre.log || die "testing config luarchive"
