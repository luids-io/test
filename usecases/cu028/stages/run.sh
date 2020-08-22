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
running_xlistd || die "xlistd is not running"
running_lunfqueue || die "lunfqueue is not running"
[ -f $CURLCMD ] || die "curl not found"

# do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: pinging unlisted"

    ping -W 1 -c 3 8.8.8.8 &>>$testlog
    [ $? -ne 0 ] && step_err "pinging google" && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: pinging listed"

    ping -W 1 -c 3 54.37.157.73 &>>$testlog
    [ $? -eq 0 ] && step_err "pinging blacklisted" && return 1

    sleep 1
    showlog_lunfqueue | grep "ip-processor.checkip" | grep -q "54.37.157.73"
    [ $? -ne 0 ] && step_err "checking log" && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
