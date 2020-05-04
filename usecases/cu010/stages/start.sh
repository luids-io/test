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
running_xlistd && die "xlistd already started"
running_ludns && die "ludns already started"

## do start
start_xlistd || die "starting xlistd"
start_ludns || die "starting ludns"
