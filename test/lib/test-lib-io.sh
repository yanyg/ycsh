#!/bin/bash

. $YCSH_PATH_INSTALL/lib/lib_io.sh

yc_echo "yc-echo"
yc_echo -e "yc-echo-e\ttab\t\tttab"

yc_print "yc-print"
yc_warn "yc-warn"

func()
{
	local arg

	for ((arg=0; arg<10; ++arg))
	do
		yc_debug "debug level is $arg"
	done
}

func

for ((arg=0; arg<10; ++arg))
do
	yc_debug "debug level is $arg"
done

x=10
y=10

yc_assert "$x -eq $y" "'$x' -eq '$z'"
yc_assert "$x -eq $y"

y=20
yc_assert '$x -eq $y'
yc_assert "$x -eq $y"

yc_exit
