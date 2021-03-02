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

    echo "$result" | grep 'returnCode" : 3' &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check resolv - store cnames"

    ## www.luisguillen.com is a cname from vps01.luisguillen.com and its ip is 54.37.157.73

    local resolved
    resolved=`$DIGDNS @localhost -p 1053 +short A www.luisguillen.com 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    echo $resolved >>$testlog
    [ "$resolved" == "" ] && step_err && return 1

    sleep 5
    local result
    local query="db.getCollection('resolvs').find({'name': 'www.luisguillen.com'})"
    result=`$MONGOCLI --quiet $USECASE_ID --eval "$query" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1

    echo "$result" | grep "vps01.luisguillen.com" &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}


test04() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    local stdoutlog=$RUNDIR/$testname-stdout.log
    step "$testname: very basic test luarchivecli"

    local list
    list=`$BINDIR/luarchivecli listresolvs --clientip 127.0.0.1 2>$testlog >$stdoutlog`
    [ $? -ne 0 ] && step_err "listresolvs --clientip 127.0.0.1" && return 1

    local counter
    counter=`cat $stdoutlog | wc -l`
    [ $counter -ne 3 ] && step_err "invalid number of records: $counter" && return 1

    local rid
    rid=`$BINDIR/luarchivecli listresolvs --name www.google.com 2>>$testlog`
    [ $? -ne 0 ] && step_err "listresolvs --name www.google.com" && return 1
    rid=`echo $rid |cut -f1 -d","`

    local tldplusone
    tldplusone=`$BINDIR/luarchivecli getresolv $rid 2>>$testlog | grep "tldPlusOne" | cut -f2 -d":" | tr -d " "`
    [ $? -ne 0 ] && step_err "getresolv" && return 1
    [ $tldplusone != "google.com" ] && step_err "invalid tldplusone: $tldplusone" && return 1

    step_ok
}



## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
test04 || die "running test04"
