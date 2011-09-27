# Do not insert sha-bang(#!) here
#
# ycsh -- yc Bash Shell Extensions
#
# Copyright (C) 2011-2012 yanyg
# All rights reserved
#
# License: GPL v2 or LGPL
# Author: yanyg
# Date: 2011-09-11
#
# ycsh library config
#
# Export symbols
#	Index	Name				Type		Description
#	1		RTN_SUCC			Integer		return success
#	2		RTN_FAIL			Integer		return failed
#	3		RTN_ERR				Integer		return error(equal to failed)
#	4		EXIT_SUCC			Integer
#	5		EXIT_FAIL			Integer
#	6		EXIT_ERR			Integer
#	7		STDIN				Integer		Stdandard input
#	8		STDOUT				Integer		Stdandard output
#	9		STDERR				Integer		Stdandard error
#	10		STDDEBUG			Integer		Stdandard debug
#	11		YCSH_PATH_INSTALL	String		Default is /usr/local/bin/ycsh
#	12		YCSH_PATH_LIB		String		Default is $YCSH_PATH_INSTALL/lib

[ "$_54058677af28b5f4ca0752bde5e86b48" = "54058677af28b5f4ca0752bde5e86b48" ] && return 0
_54058677af28b5f4ca0752bde5e86b48=54058677af28b5f4ca0752bde5e86b48

# enviroment-value
: ${YCSH_PATH_INSTALL:=/usr/local/bin/ycsh}
: ${YCSH_PATH_LIB:=$YCSH_PATH_INSTALL/lib}

# return-value
: ${YCSH_SUCC:=0}
: ${YCSH_FAIL:=1}

# input/output file descriptors
: ${YCSH_STDIN:=0}
: ${YCSH_STDOUT:=1}
: ${YCSH_STDERR:=2}
: ${YCSH_STDDEBUG:=$YCSH_STDERR}

if ! type declare >/dev/null 2>&1 || type local >/dev/null 2>&1; then
	lib_config_callback_loop()
	{
		# support local or not ? we cannot assume it.
		[ $# -lt 2 ] && return

		__tmp_callback=$1; shift

		for __tmp_loop_arg in "$@"
		do
			$__tmp_callback "$__tmp_loop_arg"
		done

		unset -v __tmp_callback __tmp_loop_arg
	}

	lib_config_callback_loop_opts()
	{
		[ $# -lt 2 ] && return
		__tmp_callback=$1; shift

		while [ -n "$1" -a -z "${1##-*}" ]
		do
			shift
		done

		lib_config_callback_loop $__tmp_callback "$@"

		unset -v __tmp_callback
	}
fi

# support declare/local ...
if ! type declare >/dev/null 2>&1; then
	declare()
	{
		# may cannot support local too.
		lib_config_callback_loop_opts eval "$@"
	}
fi
if ! type local >/dev/null 2>&1; then
	local()
	{
		# may cannot support local too.
		lib_config_callback_loop_opts eval "$@"
	}
fi

# set to readonly
lib_config_declare_attr()
{
	local arg opt opts=""

	for opt in "$@"
	do
		[ -n "${arg##-*}" ] && break
		shift
		[ "--" = "$arg" ] && break
		opts="$opts $opt"
	done

	echo "declare $opts $@"
}

eval $(lib_config_declare_attr -r YCSH_PATH_INSTALL=$YCSH_PATH_INSTALL YCSH_PATH_LIB=$YCSH_PATH_LIB)
eval $(lib_config_declare_attr -r -i RTN_SUCC=$YCSH_SUCC EXIT_SUCC=$YCSH_SUCC RTN_FAIL=$YCSH_FAIL EXIT_FAIL=$YCSH_FAIL RTN_ERR=$YCSH_FAIL EXIT_ERR=$YCSH_FAIL)
eval $(lib_config_declare_attr -r -i STDIN=$YCSH_STDIN STDOUT=$YCSH_STDOUT STDERR=$YCSH_STDERR STDDEBUG=$YCSH_STDDEBUG)

# unset internal function
unset -f lib_config_declare_attr
