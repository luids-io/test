#!/bin/bash

function defined() { [ "${!1-X}" == "${!1-Y}" ] ; }
function die() { echo "error: $@" 1>&2 ; exit 1 ; }
function warn() { echo "warn: $@" 1>&2 ; }
function msg() { echo "$@" ; }
function step() { echo -n "* $@..." ; }
function step_ok() { echo " OK" ; }
function step_err() { echo " ERROR" ; }

defined BASEDIR || die "BASEDIR is required"
defined TESTEDDIR || TESTEDDIR=$BASEDIR/tested
defined USECASESDIR || USECASESDIR=$BASEDIR/usecases

defined WAITSECS || WAITSECS=1 ## wait secs start-shutdown services

function check_connection() {
    ping -c 1 www.google.com &>/dev/null
}