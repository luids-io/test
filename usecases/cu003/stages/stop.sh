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

## do stop
stop_xlistd || warn "stopping xlistd"
stop_xlistd "domain" || warn "stopping xlistd domain"
stop_xlistd "ip" || warn "stopping xlistd ip"
