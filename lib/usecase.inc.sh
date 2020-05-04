#!/bin/bash

defined BASEDIR || die "BASEDIR is required"
defined USECASEDIR || die "USECASEDIR is required"
defined TESTEDDIR || die "TESTEDDIR is required"

defined STAGESDIR || STAGESDIR=$USECASEDIR/stages
defined DATADIR || DATADIR=$USECASEDIR/data

defined WORKDIR || WORKDIR=$USECASEDIR/work
defined BINDIR || BINDIR=$WORKDIR/bin
defined RUNDIR || RUNDIR=$WORKDIR/run
defined ETCDIR || ETCDIR=$WORKDIR/etc
defined VARDIR || VARDIR=$WORKDIR/var

## read USE CASE info
[ -f $USECASEDIR/info.json ] || die "$USECASEDIR/info.json not found"
USECASE_ID=`jq -r '.id' $USECASEDIR/info.json`
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
[ "$USECASE_ID" == "$(basename $USECASEDIR)" ] || die "info.json and dir name missmatch"
USECASE_NAME=`jq -r '.name' $USECASEDIR/info.json`
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
USECASE_TESTED=$(jq -r '(.tested // empty) |join(" ")' $USECASEDIR/info.json)
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
## read USE CASE stages
USECASE_STAGE_PREPARE=$(jq -r '(.stages.prepare // empty)' $USECASEDIR/info.json)
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
USECASE_STAGE_START=$(jq -r '(.stages.start // empty)' $USECASEDIR/info.json)
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
USECASE_STAGE_RUN=$(jq -r '(.stages.run // empty)' $USECASEDIR/info.json)
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
USECASE_STAGE_STOP=$(jq -r '(.stages.stop // empty)' $USECASEDIR/info.json)
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"
USECASE_STAGE_CLEAN=$(jq -r '(.stages.clean // empty)' $USECASEDIR/info.json)
[ $? -eq 0 ] || die "reading $USECASEDIR/info.json"

## check_tested
for binary in $USECASE_TESTED; do 
    [ -f $TESTEDDIR/$binary ] || die "${TESTEDDIR}/${binary} not found"
done

## check_stages
if [ "$USECASE_STAGE_PREPARE" != "" ]; then
    [ -x "${STAGESDIR}/${USECASE_STAGE_PREPARE}" ] || die "can't find prepare stage"
fi
if [ "$USECASE_STAGE_START" != "" ]; then
    [ -x "${STAGESDIR}/${USECASE_STAGE_START}" ] || die "can't find start stage"
fi
if [ "$USECASE_STAGE_RUN" != "" ]; then
    [ -x "${STAGESDIR}/${USECASE_STAGE_RUN}" ] || die "can't find run stage"
fi
if [ "$USECASE_STAGE_STOP" != "" ]; then
    [ -x "${STAGESDIR}/${USECASE_STAGE_STOP}" ] || die "can't find stop stage"
fi
if [ "$USECASE_STAGE_CLEAN" != "" ]; then
    [ -x "${STAGESDIR}/${USECASE_STAGE_CLEAN}" ] || die "can't find clean stage"
fi

function create_workdir() {
    mkdir -p $WORKDIR || return $?
    mkdir -p $BINDIR || return $?
    mkdir -p $RUNDIR || return $?
    mkdir -p $ETCDIR || return $?
    mkdir -p $VARDIR || return $?
}

function copy_tested() {
    [ -d $BINDIR ] || return 1
    for binary in $USECASE_TESTED; do 
        [ ! -f ${BINDIR}/$binary ] || return 1
        cp ${TESTEDDIR}/${binary} $BINDIR
    done
}

function check_connection() {
    ping -c 1 www.google.com &>/dev/null
}

function clean_workdir() {
    [ "$WORKDIR" == "/" ] && die "¡fatal! WORKDIR == /"
    rm -rf $WORKDIR
}

function exists_workdir() {
    [ -d $WORKDIR ]
}