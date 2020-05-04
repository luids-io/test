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

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check rfc ip4 status"

    local result
    result=`$DIGDNS @localhost -p 1053 +short A 2.0.0.127.rbl.mizona.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "127.0.0.69"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT 2.0.0.127.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "rfc5728"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short A 1.0.0.127.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT 1.0.0.127.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check rfc domain status"

    local result
    result=`$DIGDNS @localhost -p 1053 +short A test.rbl.mizona.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "127.0.0.69"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT test.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "rfc5728"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short A invalid.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT invalid.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check blacklist ip4 responses"

    local result
    result=`$DIGDNS @localhost -p 1053 +short A 2.2.2.2.rbl.mizona.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "127.0.0.69"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT 2.2.2.2.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "blacklisted"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short A 8.8.8.8.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT 8.8.8.8.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    step_ok
}

test04() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check blacklist domain responses"

    local result
    result=`$DIGDNS @localhost -p 1053 +short A ru.malware.has.deep.rbl.mizona.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "127.0.0.69"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT ru.malware.has.deep.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    echo $result | grep -q "blacklisted"
    [ $? -ne 0 ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short A com.google.www.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    result=`$DIGDNS @localhost -p 1053 +short TXT com.google.www.rbl.mizona.com 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $result >>$testlog
    [ "$result" != "" ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
test04 || die "running test04"
