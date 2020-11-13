#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir && die "workdir exists"

## do prepare
prepare_workdir() {
    ##config apiservices
    mkdir -p $ETCDIR/luids || return $?
    cp $DATADIR/apiservices.json $ETCDIR/luids || return $?
    
    ## prepare xlist
    mkdir -p $ETCDIR/luids/xlist || return $?
    mkdir -p $VARDIR/lib/luids/xlist || return $?
    cp $DATADIR/xlistd-main.toml $ETCDIR/luids/xlist || return $?
    cp $DATADIR/services-main.json $ETCDIR/luids/xlist || return $?
    cp $DATADIR/xlistd-view1.toml $ETCDIR/luids/xlist || return $?
    cp $DATADIR/services-view1.json $ETCDIR/luids/xlist || return $?

    ## prepare ludns
    mkdir -p $ETCDIR/luids/dns || return $?
    cp $DATADIR/Corefile $ETCDIR/luids/dns || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_xlistd "main" &>$RUNDIR/pre.log || die "testing xlistd main config"
dryrun_xlistd "view1" &>$RUNDIR/pre.log || die "testing xlistd main config"