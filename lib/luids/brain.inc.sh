#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

## manage lubrain service
function start_lubrain() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/lubrain --config $ETCDIR/luids/brain/lubrain${instance}.toml &>$RUNDIR/lubrain${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/lubrain${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_lubrain() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/lubrain${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/lubrain${instance}.pid`
    kill $SPID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_lubrain() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/lubrain${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/lubrain${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_lubrain() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/lubrain --config $ETCDIR/luids/brain/lubrain${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}
