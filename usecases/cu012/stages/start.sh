#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## increment default seconds
WAITSECS=2
## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh
. $BASEDIR/lib/luids/event.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_eventproc && die "ludns already started"
running_xlistd && die "xlistd already started"
running_ludns && die "ludns already started"


## do start
start_eventproc || die "starting eventproc"
start_xlistd || die "starting xlistd"
start_ludns || die "starting ludns"
