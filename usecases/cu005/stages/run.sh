#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/event.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_eventproc || die "eventproc is not running"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: notify event"
    
    local eid=`$BINDIR/eventnotify --file ${DATADIR}/${testname}.json 2>$testlog`
    [ $? -ne 0 ] && step_err && return 1
    sleep 1    
    grep -q "$eid" $VARDIR/lib/luids/event/security-events.json
    [ $? -ne 0 ] && step_err && return 1
    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: error with bad code"
    
    $BINDIR/eventnotify --file ${DATADIR}/${testname}.json &>$testlog
    [ $? -eq 0 ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
