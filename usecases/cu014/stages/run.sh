#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_ludns || die "ludns is not running"

cachelog=$VARDIR/lib/luids/dns/resolvcache.log
[ -f $cachelog ] || die "$cachelog doesn't exists!"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv"

    local resolved
    resolved=`$DIGDNS @localhost -p 1053 +short A www.google.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo "$resolved" >>$testlog
    [ "$resolved" == "" ] && step_err && return 1

    sleep 2

    cat $cachelog | grep "collect" | grep -q "127.0.0.1,www.google.com" 
    [ $? -ne 0 ] && step_err && return 1

    local result
    result=`$BINDIR/resolvcheck "127.0.0.1,$resolved,www.google.com" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    
    echo "$result" >>$testlog
    echo "$result" | grep -q "true"
    [ $? -ne 0 ] && step_err && return 1

    sleep 2

    cat $cachelog | grep "check" | grep -q "127.0.0.1,www.google.com" 
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check nonexist"

    local nonexists="asdf.adf3431noexiste.com"

    local resolved
    resolved=`$DIGDNS @localhost -p 1053 +short A $nonexists 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $resolved >>$testlog
    [ "$resolved" != "" ] && step_err && return 1

    sleep 2

    cat $cachelog | grep "collect" | grep -q "127.0.0.1,$nonexists"
    [ $? -eq 0 ] && step_err && return 1

    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv - cache cnames"

    ## www.luisguillen.com is a cname from vps01.luisguillen.com and its ip is 54.37.157.73

    local resolved
    resolved=`$DIGDNS @localhost -p 1053 +short A www.luisguillen.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo "$resolved" >>$testlog
    [ "$resolved" == "" ] && step_err && return 1

    sleep 2

    cat $cachelog | grep "collect" | grep -q "vps01.luisguillen.com" 
    [ $? -ne 0 ] && step_err && return 1

    local result
    result=`$BINDIR/resolvcheck "127.0.0.1,54.37.157.73,vps01.luisguillen.com" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    
    echo "$result" >>$testlog
    echo "$result" | grep -q "true"
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
