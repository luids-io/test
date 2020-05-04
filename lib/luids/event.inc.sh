#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

## manage event services
function start_eventproc() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/eventproc --config $ETCDIR/luids/event/eventproc${instance}.toml &>$RUNDIR/eventproc${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/eventproc${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_eventproc() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/eventproc${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/eventproc${instance}.pid`
    kill $SPID 2>/dev/null
    sleep $WAITSECS
}

function running_eventproc() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/eventproc${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/eventproc${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_eventproc() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/eventproc --config $ETCDIR/luids/event/eventproc${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}
