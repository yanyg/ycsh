# Do not insert sha-bang(#!) here
#
# ycsh -- yc shell
#
# Copyright (C) 2011-2012 yanyg
# All rights reserved
#
# License: GPL v2 or LGPL
# Author: yanyg
# Date: 2011-09-07
#
# Base Routines of I/O
#
# Export Symbols
#	Index	Name				Type		Description
#	3		YCSH_IO_WARN		String		Default io-warn, yes|no
#	4		YCSH_IO_DEBUG		Integer		Default io-debug, 0-9
#	5		yc_io_ctrl			Function	Set/Reset io-warn/io-debug
#	6		yc_echo				Function	echo to stdout
#	7		yc_print			Function	print to stdout
#	8		yc_warn				Function	print to stderr 
#	9		yc_debug			Function	debug to stderr
#	10		yc_exit				Function	print and exit
#	11		yc_assert			Function	assert condition

[ "$_65c7ccaa356a67a39957e9b996cb41e8" = "65c7ccaa356a67a39957e9b996cb41e8" ] && return 0
_65c7ccaa356a67a39957e9b996cb41e8=65c7ccaa356a67a39957e9b996cb41e8

# enviroment-value
: ${YCSH_PATH_LIB:=$YCSH_PATH_INSTALL/lib}

# import config
. $YCSH_PATH_LIB/lib_config.sh

# io controller
: ${YCSH_IO_WARN:=yes}
: ${YCSH_IO_DEBUG:=3}

declare io_prefix=""

yc_io_ctrl()
{
	local arg

	for arg in "$@"
	do
		arg=$(echo "$arg" | tr A-Z- a-z_)

		case "${arg%%=*}" in
			"io_warn" | "warn")
				YCSH_IO_WARN=${arg##*=}
				;;
			"io_debug" | "debug")
				arg=${arg##*=}
				[ -n "${arg##*[!0-9]*}" ] && YCSH_IO_DEBUG=$arg
				;;
			*)
				;;
		esac
	done
}

# toolbox
yc_echo()
{
	echo "$@" >& $STDOUT
}

yc_print()
{
	echo "$@" >& $STDOUT
}

yc_warn()
{
	[ "yes" = "$YCSH_IO_WARN" ] && echo "$@" >& $STDERR
}

yc_debug()
{
	local dl=$YCSH_IO_DEBUG

	if [ -n "$1" -a -z "${1#[0-9]}" ]; then
		dl=$1; shift
	fi

	[ "$dl" -ge "$YCSH_IO_DEBUG" ] && echo "<$dl> $(caller 0): $@" >& $STDERR
}

yc_exit()
{
	local status=0

	[ -n "${1##*[!0-9]*}" ] &&  { status=$1; shift; }	# if $1 is a digital, used it as exit-status

	# print other arguments out
	if [ "$#" -gt "0" ]; then
		if [ "$status" -eq "0" ]; then
			yc_print "$@"	# status iz 0, then print to STDOUT
		else
			yc_warn "$@"	# print to STDERR
		fi
	fi

	exit $status
}

yc_assert()
{
	local arg

	for arg in "$@"
	do
		# grammer check
		if [ -n "$([ $arg ] 2>&1)" ]; then
			yc_warn "assert error: '$arg' <info: $(caller 0)>"
			yc_exit $EXIT_FAIL
		fi
		if [ ! $arg ] >/dev/null 2>&1; then
			yc_warn "assert failed: '$arg'; <info: $(caller 0)>"
			yc_exit $EXIT_FAIL
		fi
	done
}
