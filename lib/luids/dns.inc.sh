#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

defined DIGDNS || DIGDNS=/usr/bin/dig
which $DIGDNS &>/dev/null || die "$DIGDNS not found"

## manage dns services
function start_ludns() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/ludns -conf $ETCDIR/luids/dns/Corefile${instance} &>$RUNDIR/ludns${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/ludns${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_ludns() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/ludns${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/ludns${instance}.pid`
    kill $SPID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_ludns() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/ludns${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/ludns${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

## manage resolvcache services
function start_resolvcache() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/resolvcache --config $ETCDIR/luids/dns/resolvcache${instance}.toml &>$RUNDIR/resolvcache${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/resolvcache${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_resolvcache() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/resolvcache${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/resolvcache${instance}.pid`
    kill $SPID 2>/dev/null
    sleep $WAITSECS
}

function running_resolvcache() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/resolvcache${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/resolvcache${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_resolvcache() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/resolvcache --config $ETCDIR/luids/dns/resolvcache${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}
