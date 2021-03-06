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
running_lunfqueue && die "lunfqueue already started"
running_xlistd && die "xlistd already started"

## do start
start_xlistd || die "starting xlistd"
start_lunfqueue || die "starting lunfqueue"
## set iptables rule
$SUDOCMD $IPTCMD -I INPUT -p icmp -j NFQUEUE --queue-num 100 || die "adding iptables rule"
