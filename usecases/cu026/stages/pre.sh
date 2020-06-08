#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/notary.inc.sh

## sanity checks
exists_workdir && die "workdir exists"
check_connection || die "internet connection required"

## do prepare
prepare_workdir() {
    ##config apiservices
    mkdir -p $ETCDIR/luids || return $?
    cp $DATADIR/apiservices.json $ETCDIR/luids || return $?    

    ##config xlist
    mkdir -p $ETCDIR/luids/xlist || return $?
    cp $DATADIR/xlistd.toml $ETCDIR/luids/xlist || return $?
    cp $DATADIR/services.json $ETCDIR/luids/xlist || return $?

    ##config tlsnotary
    mkdir -p $ETCDIR/luids/notary || return $?
    cp $DATADIR/tlsnotary.toml $ETCDIR/luids/notary || return $?
    cp $DATADIR/verifiers.json $ETCDIR/luids/notary || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
dryrun_xlistd &>$RUNDIR/pre.log || die "testing xlistd config"
dryrun_tlsnotary &>>$RUNDIR/pre.log || die "testing tlsnotary config"
