#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_xlistd "rbl1" && die "xlistd rbl1 already started"
running_xlistd "rbl2" && die "xlistd rbl2 already started"
running_ludns && die "ludns already started"

## do start
start_xlistd "rbl1" || die "starting xlistd rbl1"
start_xlistd "rbl2" || die "starting xlistd rbl2"
start_ludns || die "starting ludns"
