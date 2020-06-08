#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

## manage xlistd services
function start_xlistd() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/xlistd --config $ETCDIR/luids/xlist/xlistd${instance}.toml &>$RUNDIR/xlistd${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/xlistd${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_xlistd() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/xlistd${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/xlistd${instance}.pid`
    kill $SPID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_xlistd() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/xlistd${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/xlistd${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_xlistd() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/xlistd --config $ETCDIR/luids/xlist/xlistd${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}

function showlog_xlistd() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/xlistd${instance}.log ] || return 1
    cat $RUNDIR/xlistd${instance}.log
}

## manage xlget services
function start_xlget() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/xlget --auto --config $ETCDIR/luids/xlist/xlget${instance}.toml &>$RUNDIR/xlget${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/xlget${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_xlget() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/xlget${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/xlget${instance}.pid`
    kill $SPID 2>/dev/null
    sleep $WAITSECS
}

function running_xlget() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/xlget${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/xlget${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function run_xlget() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/xlget --config $ETCDIR/luids/xlist/xlget${instance}.toml
    ecode=$?
    popd >/dev/null
    return $ecode
}

function dryrun_xlget() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/xlget --config $ETCDIR/luids/xlist/xlget${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}
