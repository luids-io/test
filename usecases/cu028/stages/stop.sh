#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netfilter.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"

## remove iptables rule
$SUDOCMD $IPTCMD -D INPUT -p icmp -j NFQUEUE --queue-num 100 || warn "removing iptables rule"
## do stop
stop_lunfqueue || warn "stopping lunfqueue"
stop_xlistd || warn "stopping xlistd"
