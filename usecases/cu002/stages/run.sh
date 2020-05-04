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
running_xlistd || die "xlistd is not running"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check status"
    
    $BINDIR/xlistc &>$testlog
    [ $? -ne 0 ] && step_err && return 1
    
    grep -q "[ip4]" $testlog
    [ $? -ne 0 ] && step_err && return 1
    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check non exist"
    
    $BINDIR/xlistc 127.0.0.1 &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    $BINDIR/xlistc 8.8.8.8 &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "true" $testlog
    [ $? -eq 0 ] && step_err && return 1
    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check exists"
    
    $BINDIR/xlistc 127.0.0.2 &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "barracuda" $testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "ZEN2" $testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "ZEN4" $testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

test04() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check testfile"
    
    $BINDIR/xlistc -f $DATADIR/$testname.txt &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "^ip4,127.0.0.2: true" $testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "^ip4,127.0.0.4: true" $testlog | grep -q "ZEN4"
    [ $? -eq 0 ] && step_err && return 1

    step_ok
}


## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
test04 || die "running test04"
