#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

defined SUDOCMD || SUDOCMD=/usr/bin/sudo
[ -f $SUDOCMD ] || die "$SUDOCMD not found"

## manage netanalyze services
function start_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $SUDOCMD $BINDIR/netanlocal --config $ETCDIR/luids/netanalyze/netanlocal${instance}.toml &>$RUNDIR/netanlocal${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/netanlocal${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    $SUDOCMD kill -s 0 $SPID 2>/dev/null
}

function stop_netanlocal() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanlocal${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/netanlocal${instance}.pid`
    ## get child pid of sudo child process because sudo masks signals
    ## if signals are received from the same group of process
    local childID=`ps -h -o pid --ppid $SPID`
    $SUDOCMD kill $childID 2>/dev/null
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
    $SUDOCMD kill -s 0 $SPID 2>/dev/null
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

function start_netanclient() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $SUDOCMD $BINDIR/netanclient --config $ETCDIR/luids/netanalyze/netanclient${instance}.toml &>$RUNDIR/netanclient${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/netanclient${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    $SUDOCMD kill -s 0 $SPID 2>/dev/null
}

function stop_netanclient() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanclient${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/netanclient${instance}.pid`
    ## get child pid of sudo child process because sudo masks signals
    ## if signals are received from the same group of process
    local childID=`ps -h -o pid --ppid $SPID`
    $SUDOCMD kill $childID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_netanclient() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanclient${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/netanclient${instance}.pid`
    $SUDOCMD kill -s 0 $SPID 2>/dev/null
}

function showlog_netanclient() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanclient${instance}.log ] || return 1
    cat $RUNDIR/netanclient${instance}.log
}

function start_netanserver() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/netanserver --config $ETCDIR/luids/netanalyze/netanserver${instance}.toml &>$RUNDIR/netanserver${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/netanserver${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_netanserver() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanserver${instance}.pid ] || return 1    
    SPID=`cat $RUNDIR/netanserver${instance}.pid`
    sudo kill $SPID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_netanserver() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanserver${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/netanserver${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_netanserver() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/netanserver --config $ETCDIR/luids/netanalyze/netanserver${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}

function showlog_netanserver() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/netanserver${instance}.log ] || return 1
    cat $RUNDIR/netanserver${instance}.log
}

function run_netanoffline() {
    [ $# -eq 1 ] || die "invalid number of params"
    local pcapfile=$1
    [ -f "$pcapfile" ] || return 1

    pushd $WORKDIR >/dev/null
    $BINDIR/netanoffline --config $ETCDIR/luids/netanalyze/netanoffline.toml -i $pcapfile &>$RUNDIR/netanoffline.log
    ecode=$?
    popd >/dev/null
    return $ecode
}

function showlog_netanoffline() {
    [ -f $RUNDIR/netanoffline.log ] || return 1
    cat $RUNDIR/netanoffline.log
}
