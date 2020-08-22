#!/bin/bash

defined BINDIR || die "BINDIR not defined"
defined RUNDIR || die "RUNDIR not defined"
defined ETCDIR || die "ETCDIR not defined"
defined VARDIR || die "VARDIR not defined"

defined SUDOCMD || SUDOCMD=/usr/bin/sudo
[ -f $SUDOCMD ] || die "$SUDOCMD not found"

defined IPTCMD || IPTCMD=/usr/sbin/iptables
[ -f $IPTCMD ] || die "$IPTCMD not found"

## manage netfilter services
function start_lunfqueue() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    pushd $WORKDIR >/dev/null
    $SUDOCMD $BINDIR/lunfqueue --config $ETCDIR/luids/netfilter/lunfqueue${instance}.toml &>$RUNDIR/lunfqueue${instance}.log &
    SPID=$!
    echo "$SPID" >$RUNDIR/lunfqueue${instance}.pid
    popd >/dev/null
    sleep $WAITSECS
    ## check pid
    $SUDOCMD kill -s 0 $SPID 2>/dev/null
}

function stop_lunfqueue() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/lunfqueue${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/lunfqueue${instance}.pid`
    ## get child pid of sudo child process because sudo masks signals
    ## if signals are received from the same group of process
    local childID=`ps -h -o pid --ppid $SPID`
    $SUDOCMD kill $childID 2>/dev/null
    local ecode=$?
    sleep $WAITSECS
    return $ecode
}

function running_lunfqueue() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/lunfqueue${instance}.pid ] || return 1
    SPID=`cat $RUNDIR/lunfqueue${instance}.pid`
    $SUDOCMD kill -s 0 $SPID 2>/dev/null
}

function dryrun_lunfqueue() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    local ecode
    pushd $WORKDIR >/dev/null
    $BINDIR/lunfqueue --config $ETCDIR/luids/netfilter/lunfqueue${instance}.toml --dry-run
    ecode=$?
    popd >/dev/null
    return $ecode
}

function showlog_lunfqueue() {
    local instance=$1
    if [ "$instance" != "" ]; then
        instance="-$instance"
    fi
    [ -f $RUNDIR/lunfqueue${instance}.log ] || return 1
    cat $RUNDIR/lunfqueue${instance}.log
}
