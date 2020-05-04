#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/archive.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_luarchive || die "luarchive is not running"
running_ludns || die "ludns is not running"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv"

    local resolved
    resolved=`$DIGDNS @localhost -p 1053 +short A www.google.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $resolved >>$testlog
    [ "$resolved" == "" ] && step_err && return 1

    sleep 5
    local result
    local query="db.getCollection('resolvs').find({'name': 'www.google.com'})"
    result=`$MONGOCLI --quiet $USECASE_ID --eval "$query" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1

    echo "$result" | grep "$resolved" &>>$testlog
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

    sleep 5
    local result
    local query="db.getCollection('resolvs').find({'name': '$nonexists'})"
    result=`$MONGOCLI --quiet $USECASE_ID --eval "$query" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1

    echo "$result" | grep 'returncode" : 3' &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
