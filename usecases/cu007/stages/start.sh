#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## increment default seconds
WAITSECS=3
## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/event.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_eventproc && die "eventproc already started"
running_eventproc "forward" && die "eventproc forward already started"

## do start
start_eventproc || die "starting eventproc"
start_eventproc "forward" || die "starting eventproc forward"
