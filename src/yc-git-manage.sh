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
	yc_echo -e "\nUsage:"
	yc_echo -e "  $self [Options]        manage git-repositories"
	yc_echo -e "\nOptions"
	yc_echo -e "  -h, --help             print help"
	yc_echo -e "  -p, --push=repo.git    push repository"
	yc_echo -e "  -g, --pull=repo.git    pull repository"
	yc_echo -e "  -u, --user=user        execution user"
	yc_echo -e "  -h, --host=hostname    hostname of git"
	yc_echo -e "  -b, --base=base-dir    base directory of repositories"
	yc_echo -e "\n"

	yc_exit $1
}

remote_do()
{
	echo -n " ... "
	local val
	val=$(ssh $git_user_args@$git_host_args $@ 2>&1)
	if [ $? -eq 0 ]; then
		echo "ok"
	else
		echo "failed <err: $val>"
	fi
}

push()
{
	local repo
	for repo in $git_push_args
	do
		[ -n "${repo%%*.git}" ] && continue
		echo -n "push $git_base_args/$repo"
		remote_do "cd $git_base_args/$repo && git push"
	done

	exit 0
}

pull()
{
	local repo
	for repo in $git_pull_args
	do
		[ -n "${repo%%*.git}" ] && continue
		echo -n "pull $git_base_args/$repo"
		remote_do "cd $git_base_args/$repo && git remote update"
	done

	exit 0
}

[ $# -ne 0 ] || usage

val=$(yc_getopt "git,args" "true" "help,h,::" "push,p,:" "pull,g,:" "user,u,::" "host,h,::" "base,b,::" -- "$@")

[ -n "$val" ] && eval declare "$val"

: ${git_user_args:=git}
: ${git_host_args:=t410.ssh}
: ${git_base_args:=repositories}

yc_var_isdeclared git_help_args && usage

yc_var_isdeclared git_push_args && push

yc_var_isdeclared git_pull_args && pull

yc_exit 1 " $self: You must specify push|pull, run '$self -h' for details"
