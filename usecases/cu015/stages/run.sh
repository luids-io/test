#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/archive.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_luarchive || die "luarchive is not running"

# do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: tlsarchivepcap"

    $BINDIR/tlsarchivepcap -i $TMPDIR/capture-001.cap --mongodb.db $USECASE_ID --mongodb.prefix $testname &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    sleep 3
    local result
    local query="db.getCollection('${testname}_connections').count({'clienthello.extensioninfo.sni': 'www.luisguillen.com'})"
    result=`$MONGOCLI --quiet $USECASE_ID --eval "$query" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1

    echo "$result" | grep "56" &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: tlsapconv and tlsarchiveap"

    $BINDIR/tlsapconv -i $TMPDIR/capture-001.cap -o $TMPDIR/$testname.tlsap &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    $BINDIR/tlsarchiveap -t $TMPDIR/$testname.tlsap --mongodb.db $USECASE_ID --mongodb.prefix $testname &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    sleep 3
    local result
    local query="db.getCollection('${testname}_connections').count({'clienthello.extensioninfo.sni': 'www.luisguillen.com'})"
    result=`$MONGOCLI --quiet $USECASE_ID --eval "$query" 2>>$testlog`
    [ $? -ne 0 ] && step_err && return 1

    echo "$result" | grep "56" &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}


## run tests
test01 || die "running test01"
test02 || die "running test02"
