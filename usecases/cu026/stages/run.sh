#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/notary.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_tlsnotary || die "tlsnotary is not running"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: basic verify and view xlist checks"

    local ip chain digest digests
    ip=`$DIGDNS +short -t A www.luisguillen.com | grep -v luisguillen 2>/dev/null`
    [ $? -ne 0 ] && step_err "resolving ip" && return 1

    chain=`$BINDIR/tlsnotarycli getserverchain $ip | cut -f2 -d" " 2>$testlog`
    [ $? -ne 0 ] && step_err "running tlsnotarycli getserverchain" && return 1
    sleep 2

    showlog_tlsnotary | grep -q "chain=$chain"
    [ $? -ne 0 ] && step_err "chain not seen in log" && return 1

    digests=`$BINDIR/tlsnotarycli downloadcerts $chain | cut -f1 -d":"` 2>>$testlog
    [ $? -ne 0 ] && step_err "running tlsnotarycli downloadcerts" && return 1

    $BINDIR/tlsnotarycli verifychain $chain &>>$testlog
    [ $? -ne 0 ] && step_err "running tlsnotarycli verifychain" && return 1
    sleep 1

    for digest in $digests; do
        showlog_xlistd | grep "root:" | grep "'$digest'" >>$testlog
        [ $? -ne 0 ] && step_err "digest not seen in xlistd log" && return 1
    done

    step_ok
}

## run tests
test01 || die "running test01"
