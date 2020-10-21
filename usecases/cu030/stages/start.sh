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
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_xlistd "main" && die "xlistd main already started"
running_xlistd "view1" && die "xlistd main already started"
running_ludns && die "ludns already started"

## do start
start_xlistd "main" || die "starting xlistd main"
start_xlistd "view1" || die "starting xlistd view1"
start_ludns || die "starting ludns"
