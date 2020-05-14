#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

defined MONGOCLI || MONGOCLI=/usr/bin/mongo
[ -f $MONGOCLI ] || die "$MONGOCLI not found"

function check_mongo() {
    $MONGOCLI --eval 'db.version()' &>/dev/null
}

## manage luarchive services
function start_luarchive() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $BINDIR/luarchive --config $ETCDIR/luids/archive/luarchive${instance}.toml &>$RUNDIR/luarchive${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/luarchive${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    kill -s 0 $SPID 2>/dev/null
}

function stop_luarchive() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/luarchive${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/luarchive${instance}.pid`
    kill $SPID 2>/dev/null
    sleep $WAITSECS
}

function running_luarchive() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/luarchive${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/luarchive${instance}.pid`
    kill -s 0 $SPID 2>/dev/null
}

function dryrun_luarchive() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/luarchive --config $ETCDIR/luids/archive/luarchive${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}
