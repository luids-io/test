#!/bin/bash

function defined() { [ "${!1-X}" == "${!1-Y}" ] ; }
function die() { echo "error: $@" 1>&2 ; exit 1 ; }
function warn() { echo "warn: $@" 1>&2 ; }
function msg() { echo "$@" ; }
function step() { echo -n "* $@..." ; }
function step_ok() { echo " OK" ; }
function step_err() { if [ $# -ne 0 ]; then echo " ERROR: $@" ; else echo " ERROR" ; fi; }

defined BASEDIR || die "BASEDIR is required"
## read custom environment
[ -f $BASEDIR/.env ] && source $BASEDIR/.env

defined TESTEDDIR || TESTEDDIR=$BASEDIR/tested
defined USECASESDIR || USECASESDIR=$BASEDIR/usecases
defined WAITSECS || WAITSECS=1 ## wait secs start-shutdown services

which jq >/dev/null || die "jq is required"

function check_connection() {
    ping -c 1 www.google.com &>/dev/null
}

function check_localip() {
    ip addr show | grep -q "inet $1/"
}
