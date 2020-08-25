#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

LOCALIP="${LOCALIP:-192.168.69.120}"

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netfilter.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_resolvcache || die "resolvcache is not running"
running_lunfqueue || die "lunfqueue is not running"
[ -f $CURLCMD ] || die "curl not found"

# do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: pinging unresolved"

    ping -W 1 -c 3 8.8.8.8 &>>$testlog
    [ $? -eq 0 ] && step_err "pinging unresolved" && return 1

    showlog_lunfqueue | grep "ip-processor.checkresolv" | grep -q "8.8.8.8"
    [ $? -ne 0 ] && step_err "checking log" && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: pinging resolved"

    $BINDIR/resolvcollect $LOCALIP,www.luisguillen.com,54.37.157.73 &>$testlog
    [ $? -ne 0 ] && step_err "running resolv collect with LOCALIP=$LOCALIP" && return 1

    ping -W 1 -c 3 54.37.157.73 &>>$testlog
    [ $? -ne 0 ] && step_err "pinging resolved" && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
