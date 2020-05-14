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
exists_workdir || die "workdir doesn't exists"
running_netanserver && die "netanserver already started"
running_netanclient && die "netanclient already started"

## do start
start_netanserver || die "starting netanserver"
start_netanclient || die "starting netanclient"
