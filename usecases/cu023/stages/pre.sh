#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netanalyze.inc.sh

## sanity checks
exists_workdir && die "workdir exists"

## do prepare
prepare_workdir() {
    ##config apiservices
    mkdir -p $ETCDIR/luids || return $?
    
    ##config luarchive
    mkdir -p $ETCDIR/luids/netanalyze || return $?
    cp $DATADIR/netanoffline.toml $ETCDIR/luids/netanalyze || return $?
    cp $DATADIR/plugins.json $ETCDIR/luids/netanalyze || return $?

    ##config cap files
    cp $DATADIR/*.cap $TMPDIR || return $?
}

create_workdir || die "creating workdir"
copy_tested || die "copy tested binaries"
prepare_workdir || die "preparing workdir"
