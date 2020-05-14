#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netanalyze.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_netanserver || die "netanserver is not running"
running_netanclient || die "netanclient is not running"

# do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: capture and view clienthello"

    curl "https://www.luisguillen.com" &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    sleep 1
    showlog_netanserver | grep -q "www.luisguillen.com"
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
