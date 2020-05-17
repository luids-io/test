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
exists_workdir || die "workdir doesn't exists"
running_netanlocal && die "netanlocal already started"
running_lubrain && die "lubrain already started"

## do start
start_lubrain || die "starting lubrain"
start_netanlocal || die "starting netanlocal"
