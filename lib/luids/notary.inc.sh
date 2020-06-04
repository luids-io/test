#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

## manage event services
function start_tlsnotary() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/tlsnotary --config $ETCDIR/luids/notary/tlsnotary${instance}.toml &>$RUNDIR/tlsnotary${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/tlsnotary${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_tlsnotary() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/tlsnotary${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/tlsnotary${instance}.pid`
    kill $SPID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_tlsnotary() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/tlsnotary${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/tlsnotary${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_tlsnotary() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/tlsnotary --config $ETCDIR/luids/notary/tlsnotary${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}

function showlog_tlsnotary() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/tlsnotary${instance}.log ] || return 1
    cat $RUNDIR/tlsnotary${instance}.log
}
