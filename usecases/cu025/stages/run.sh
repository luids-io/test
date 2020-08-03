#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## curl opts
CURLCMD=/usr/bin/curl



## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netanalyze.inc.sh
. $BASEDIR/lib/luids/notary.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_tlsnotary || die "tlsnotary is not running"
running_netanlocal || die "netanlocal is not running"
[ -f $CURLCMD ] || die "curl not found"

# do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: capture and test notary checks"

    ## disable session for upload certs
    CURLOPT="--tlsv1.2 --no-keepalive --tls-max 1.2 --no-sessionid"
    $CURLCMD $CURLOPT "https://www.luisguillen.com" &>$testlog
    [ $? -ne 0 ] && step_err "running curl" && return 1

    sleep 2
    showlog_netanlocal | grep "tls-inspect.notary" | grep "sni=www.luisguillen.com" | grep -q "Invalid:false"
    [ $? -ne 0 ] && step_err "verify not found" && return 1

    ## use tls1.3 to hide certs
    CURLOPT="--tlsv1.3"
    $CURLCMD $CURLOPT "https://www.luisguillen.com" &>>$testlog
    [ $? -ne 0 ] && step_err "running curl" && return 1

    sleep 2
    showlog_netanlocal | grep "tls-inspect.notary" | grep "sni=www.luisguillen.com" | grep -q "Invalid:false"
    [ $? -ne 0 ] && step_err "verify not found" && return 1

    step_ok
}

## run tests
test01 || die "running test01"
