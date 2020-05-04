#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_xlistd && die "xlistd already started"
running_xlistd "ip" && die "xlistd ip already started"
running_xlistd "domain" && die "xlistd domain already started"

## do start
start_xlistd "ip" || die "starting xlistd ip"
start_xlistd "domain" || die "starting xlistd domain"
start_xlistd || die "starting xlistd"
