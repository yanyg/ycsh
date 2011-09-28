# Do not insert sha-bang(#!) here
#
# ycsh -- yc shell
#
# Copyright (C) 2011-2012 yanyg
# All rights reserved
#
# License: GPL v2 or LGPL
# Author: yanyg
# Date: 2011-09-11
#
# variable attr.
#
# Export Symbols
#	Index	Name				Type		Description
#

[ "$_21904b9fddb5578be9cd4798d94d4242" = "21904b9fddb5578be9cd4798d94d4242" ] && return 0
_21904b9fddb5578be9cd4798d94d4242=21904b9fddb5578be9cd4798d94d4242

# enviroment-value
: ${YCSH_PATH_LIB:=$YCSH_PATH_INSTALL/lib}

# import config
. $YCSH_PATH_LIB/lib_config.sh
. $YCSH_PATH_LIB/lib_ctype.sh

# usage: __yc_var_loop callback arg[,...]
__yc_var_loop()
{
	local arg callback=$1; shift

	for arg in "$@"
	do
		$callback "$arg" || return $RTN_FAIL
	done

	return $RTN_SUCC
}

# arg is grammer-valid variable name or not
yc_isvarname()
{
	__yc_isvarname() { [ -n "${1##[0-9]*}" -a -n "${1##*[!A-Za-z0-9_]*}" ]; }
	__yc_var_loop __yc_isvarname "$@"
}

yc_isdeclared()
{
	__yc_isdeclared()
	{
		yc_isvarname "$1" && {
			[ -n "$(eval echo "\$$1")" ] || [ -z "$(eval echo "\${$1-s}")" ]
		}
	}

	__yc_var_loop __yc_isdeclared "$@"
}

yc_genvar()
{
	__yc_genvar()
	{
		local name=${1%%=*} value=${1##*=}

		[ -n "$name" ] || return $RTN_FAIL
	
		name=$(echo -n "$name" |tr "[:cntrl:][:punct:][:space:]" "_")
		[ -z "${name##[0-9]*}" ] && name="_$var"
		[ -n "$value" ] && value="='$value'"

		echo -n "$name$value "
	}

	local var_report=$(__yc_var_loop __yc_genvar "$@")
	echo "${var_report% }"
}
