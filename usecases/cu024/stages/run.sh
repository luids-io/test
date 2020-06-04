#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/dns.inc.sh
. $BASEDIR/lib/luids/notary.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_tlsnotary || die "tlsnotary is not running"

## do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: basic getserverchain"

    local ip chain
    ip=`$DIGDNS +short -t A www.luisguillen.com | grep -v luisguillen 2>/dev/null`
    [ $? -ne 0 ] && step_err "resolving ip" && return 1

    chain=`$BINDIR/tlsnotarycli getserverchain $ip | cut -f2 -d" " 2>$testlog`
    [ $? -ne 0 ] && step_err "running tlsnotarycli" && return 1
    sleep 2

    showlog_tlsnotary | grep -q "chain=$chain"
    [ $? -ne 0 ] && step_err "chain not seen in log" && return 1
    step_ok
}

test02() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: basic getserverchain and verify"

    ## get ip adress
    local ip chain result
    ip=`$DIGDNS +short -t A www.luisguillen.com | grep -v luisguillen 2>/dev/null`
    [ $? -ne 0 ] && step_err "resolving ip" && return 1

    chain=`$BINDIR/tlsnotarycli getserverchain $ip --sni www.luisguillen.com | cut -f2 -d" " 2>$testlog`
    [ $? -ne 0 ] && step_err "running getserverchain" && return 1
    sleep 2

    result=`$BINDIR/tlsnotarycli verifychain $chain 2>>$testlog`
    [ $? -ne 0 ] && step_err "running verifychain" && return 1

    echo "$result" | grep -q "OK"
    [ $? -ne 0 ] && step_err "bad verification" && return 1

    result=`$BINDIR/tlsnotarycli verifychain $chain --dnsname=www.luisguillen.com 2>>$testlog`
    [ $? -ne 0 ] && step_err "running verifychain with dnsname" && return 1

    echo "$result" | grep -q "OK"
    [ $? -ne 0 ] && step_err "bad verification with dnsname" && return 1

    step_ok
}

test03() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: basic getserverchain and bad verify"

    ## get ip adress
    local ip chain result
    ip=`$DIGDNS +short -t A www.luisguillen.com | grep -v luisguillen 2>/dev/null`
    [ $? -ne 0 ] && step_err "resolving ip" && return 1

    chain=`$BINDIR/tlsnotarycli getserverchain $ip --sni www.luisguillen.com | cut -f2 -d" " 2>$testlog`
    [ $? -ne 0 ] && step_err "running getserverchain" && return 1
    sleep 2

    result=`$BINDIR/tlsnotarycli verifychain $chain --dnsname=www.otherdomain.com 2>>$testlog`
    [ $? -ne 0 ] && step_err "running verifychain" && return 1

    echo "$result" | grep -q "INVALID"
    [ $? -ne 0 ] && step_err "bad verification" && return 1

    ## on invented chain, it returns error to shell
    $BINDIR/tlsnotarycli verifychain "inventeeeddd" &>>$testlog
    [ $? -eq 0 ] && step_err "running verifychain (invented chain)" && return 1

    showlog_tlsnotary | grep "inventeeeddd" | grep -q "chain not found"
    [ $? -ne 0 ] && step_err "chain not seen in log" && return 1

    step_ok
}

## run tests
test01 || die "running test01"
test02 || die "running test02"
test03 || die "running test03"

