#!/bin/bash

## define required variables
SCRIPTDIR=$(dirname $(readlink -f "$0"))
USECASEDIR=$(dirname $SCRIPTDIR)
BASEDIR=`dirname $(dirname $USECASEDIR)`

## curl opts
CURLCMD=/usr/bin/curl
# disable reuse of session and use 1.2 because it needs certifcates
CURLOPT="--tlsv1.2 --no-keepalive --no-sessionid"

## include libs
. $BASEDIR/lib/core.inc.sh
. $BASEDIR/lib/usecase.inc.sh
. $BASEDIR/lib/luids/netanalyze.inc.sh
. $BASEDIR/lib/luids/xlist.inc.sh

## sanity checks
exists_workdir || die "workdir doesn't exists"
running_xlistd || die "xlistd is not running"
running_netanlocal || die "netanlocal is not running"
[ -f $CURLCMD ] || die "curl not found"

# do tests
test01() {
    local testname=$FUNCNAME
    local testlog=$RUNDIR/$testname.log
    step "$testname: capture and test xlist checks"

    $CURLCMD $CURLOPT "https://www.luisguillen.com" &>$testlog
    [ $? -ne 0 ] && step_err && return 1

    sleep 5
    showlog_netanlocal | grep "tls-inspect.checkip" | grep -q "54.37.157.73"
    [ $? -ne 0 ] && step_err && return 1

    showlog_netanlocal | grep "tls-inspect.checksni" | grep -q "www.luisguillen.com"
    [ $? -ne 0 ] && step_err && return 1

    showlog_netanlocal | grep "tls-inspect.checkja3" | grep -q "00bcd759cb8ad485fdbf1e7a0c5b94b4"
    [ $? -ne 0 ] && step_err && return 1

    showlog_netanlocal | grep -q "tls-inspect.checkcertfp"
    [ $? -ne 0 ] && step_err && return 1

    step_ok
}

## run tests
test01 || die "running test01"
