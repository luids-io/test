#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
check_connection || die "checking connection"

doClean() {
    rm -f $ETCDIR/luids/xlist/sources.d/abuse-ch.json
    rm -f $VARDIR/lib/luids/xlist/*.xlist*
}

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: download sources"
    
    run_xlget &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    cat $testlog | grep -q "summary 'alienvault.com'"
    [ $? -ne 0 ] && step_err && return 1
    
    [ ! -f $WORKDIR/var/lib/luids/xlist/alienvault.com.xlist ] \
        && step_err && return 1

    [ ! -f $WORKDIR/var/lib/luids/xlist/alienvault.com.xlist.md5 ] \
        && step_err && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: don't update if cached"
    
    run_xlget &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    cat $testlog | grep -q "summary 'alienvault.com'"
    [ $? -eq 0 ] && step_err && return 1
    
    [ ! -f $WORKDIR/var/lib/luids/xlist/alienvault.com.xlist ] \
        && step_err && return 1

    [ ! -f $WORKDIR/var/lib/luids/xlist/alienvault.com.xlist.md5 ] \
        && step_err && return 1

    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: add new source"

    cat > $WORKDIR/etc/luids/xlist/sources.d/abuse-ch.json <<EOF
[
    {
        "id": "abuse.ch-urlhaus",
        "sources": [
            {
                "format": "hosts",
                "resources": [
                    "domain"
                ],
                "uri": "https://urlhaus.abuse.ch/downloads/hostfile/",
                "filename": "hostfile.txt"
            }
        ],
        "update": "1h"
    }
]
EOF
    run_xlget &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    ## check downloaded
    cat $testlog | grep -q "summary 'abuse.ch-urlhaus'"
    [ $? -ne 0 ] && step_err && return 1

    [ ! -f $WORKDIR/var/lib/luids/xlist/abuse.ch-urlhaus.xlist ] \
        && step_err && return 1

    ## check don't download    
    cat $testlog | grep -q "summary 'alienvault.com'"
    [ $? -eq 0 ] && step_err && return 1

    step_ok
}

## run tests
doClean
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
