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
# character classification routines
#
# Export Symbols
#	Index	Name				Type		Description
#

[ "$_bda7e34f01d1f1874f7c2a29cf5ab9a4" = "bda7e34f01d1f1874f7c2a29cf5ab9a4" ] && return 0
_bda7e34f01d1f1874f7c2a29cf5ab9a4=bda7e34f01d1f1874f7c2a29cf5ab9a4

# enviroment-value
: ${YCSH_PATH_LIB:=$YCSH_PATH_INSTALL/lib}

# import config
. $YCSH_PATH_LIB/lib_config.sh

# usage: __yc_ctype_loop csets arg[,...]
__yc_ctype_loop()
{
	local arg csets=$1; shift

	for arg in "$@"
	do
		[ -z "${arg##*[!$csets]*}" ] && return $RTN_FAIL
	done

	return $RTN_SUCC
}

yc_isalnum()
{
	__yc_ctype_loop "A-Za-z0-9" "$@"
}

yc_isalpha()
{
	__yc_ctype_loop "A-Za-z" "$@"
}

yc_isdigit()
{
	__yc_ctype_loop "0-9" "$@"
}

yc_isodigit()
{
	__yc_ctype_loop "0-7" "$@"
}

yc_isxdigit()
{
	local arg
	for arg in "$@"
	do
		arg=${arg#0[xX]}
		[ -z "${arg##*[!0-9A-Fa-f]*}" ] && return $RTN_FAIL
	done

	return $RTN_SUCC
}
