#!/bin/bash
#
# ycsh -- yc Bash Shell Extensions
#
# Copyright (C) 2011-2012 yanyg
# All rights reserved
#
# License: GPL v2 or LGPL
# Author: yanyg
# Date: 2011-10-13
#
# yc-git-manage: git manage
#

# enviroment-value
: ${YCSH_PATH_INSTALL:=/usr/local/bin/ycsh}
: ${YCSH_PATH_LIB:=$YCSH_PATH_INSTALL/lib}

. $YCSH_PATH_INSTALL/lib/lib_config.sh || echo "source '$YCSH_PATH_INSTALL/lib_config.sh' failed, check enviroment value YCSH_PATH_INSTALL"

yc_source lib_getopt.sh

declare -r self=$(basename $0)

usage()
{
	local -i exit=0

	[ $# -ne 0 ] && exit=$1

	yc_echo -e "\nUsage:"
	yc_echo -e " $self [Options]\t\tmanage git-repositories"
	yc_echo -e "\nOptions"
	yc_echo -e " -h, --help\t\t\t\tprint help"
	yc_echo -e "\n"

	exit $exit
}

push()
{
	:
	exit 0
}

pull()
{
	:
	exit 0
}

[ $# -ne 0 ] || usage

declare $(yc_getopt "git,args" "true" "help,h,::" "push,s,::" "pull,l,::" -- "$@")

yc_var_isdeclared git_help_args && usage

yc_var_isdeclared git_push_args && push

yc_var_isdeclared git_pull_args && pull

yc_exit 1 " $self: You must specify push|pull, run '$self -h' for details"
