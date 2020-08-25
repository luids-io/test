#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netanalyze.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_netanlocal && die "netanlocal is running"
running_xlistd && die "xlistd is running"

## do clean
clean_workdir
