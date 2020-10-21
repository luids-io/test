#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

LOCALIP="${LOCALIP:-192.168.69.120}"

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_xlistd "main" || die "xlistd main is not running"
running_xlistd "view1" || die "xlistd view1 is not running"
running_ludns || die "ludns is not running"
check_connection || die "checking connection"
check_localip $LOCALIP || die "LOCALIP $LOCALIP not found"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv unlisted by the view"

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
    step "$testname: check resolv blacklisted by the view"

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

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv unlisted by default"

    local result
    result=`$DIGDNS @$LOCALIP -p 1053 +short A www.facebook.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" == "" ] && step_err && return 1

    step_ok
}

test04() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv blacklisted by default"

    local result
    result=`$DIGDNS @$LOCALIP -p 1053 +short A www.google.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    sleep 1
    cat $RUNDIR/ludns.log | grep "www.google.com" | grep "blacklisted" &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}


## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
test04 || die "running test04"
