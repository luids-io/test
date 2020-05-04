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
running_xlistd || die "xlistd is not running"
running_ludns || die "ludns is not running"
check_connection || die "checking connection"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv unlisted"

    local result
    result=`$DIGDNS @localhost -p 1053 +short A www.google.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" == "" ] && step_err && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv blacklisted"

    local result
    result=`$DIGDNS @localhost -p 1053 +short A www.facebook.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    sleep 1
    cat $RUNDIR/ludns.log | grep "www.facebook.com" | grep "blacklisted" &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
