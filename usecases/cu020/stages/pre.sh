#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netanalyze.inc.sh
. $BASEDIR/lib/luids/brain.inc.sh

## sanity checks
exists_workdir && die "workdir exists"
check_connection || die "internet connection required"

## do prepare
prepare_workdir() {
    ##config apiservices
    mkdir -p $ETCDIR/luids || return $?
    cp $DATADIR/apiservices.json $ETCDIR/luids || return $?    

    ##config netanalyze
    mkdir -p $ETCDIR/luids/netanalyze || return $?
    cp $DATADIR/netanlocal.toml $ETCDIR/luids/netanalyze || return $?
    cp $DATADIR/plugins.json $ETCDIR/luids/netanalyze || return $?

    ##config lubrain
    mkdir -p $ETCDIR/luids/brain || return $?
    cp $DATADIR/lubrain.toml $ETCDIR/luids/brain || return $?
    cp $DATADIR/backends.json $ETCDIR/luids/brain || return $?
    cp $DATADIR/classifiers.json $ETCDIR/luids/brain || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_netanlocal &>$RUNDIR/pre.log || die "testing config netanlocal"
dryrun_lubrain &>$RUNDIR/pre.log || die "testing config lubrain"
