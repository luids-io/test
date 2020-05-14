#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

## manage netanalyze services
function start_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    sudo $BINDIR/netanlocal --config $ETCDIR/luids/netanalyze/netanlocal${instance}.toml &>$RUNDIR/netanlocal${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/netanlocal${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    sudo kill -s 0 $SPID 2>/dev/null
}

function stop_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanlocal${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/netanlocal${instance}.pid`
    sudo kill $SPID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanlocal${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/netanlocal${instance}.pid`
    sudo kill -s 0 $SPID 2>/dev/null
}

function dryrun_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/netanlocal --config $ETCDIR/luids/netanalyze/netanlocal${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}

function showlog_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanlocal${instance}.log ] || return 1
    cat $RUNDIR/netanlocal${instance}.log
}
