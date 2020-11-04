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
check_connection || die "checking connection"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check status"
    
    $BINDIR/xlistc &>$testlog
    [ $? -ne 0 ] && step_err && return 1
    
    grep -q "[domain]" $testlog
    [ $? -ne 0 ] && step_err && return 1

    [ ! -f $VARDIR/lib/luids/xlist/sb-phising.db ] && step_err "database sb-phising not found" && return 1
    [ ! -f $VARDIR/lib/luids/xlist/sb-malware.db ] && step_err "database sb-malware not found" && return 1

    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check non exist"

    $BINDIR/xlistc www.google.com &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    $BINDIR/xlistc www.luisguillen.com &>>$testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check exists sb-malware"

    ##2020-11-04: some listed domains: 
    local bldomains="189zx.com www.robtozier.com kamerreklam.com.tr staffsolut.nichost.ru"
    $BINDIR/xlistc $bldomains &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "sb-malware" $testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

test04() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: check exists sb-phising"

    ##2020-11-04: some listed domains: 
    local bldomains="fabriguard.com touroflimassol.com ymcmt.com zdravets.org shuklaenterprises.in rooijen.org codeaweb.net"
    $BINDIR/xlistc $bldomains &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    grep -q "sb-phising" $testlog
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}


## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"
test04 || die "running test04"
