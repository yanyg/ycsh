#!/bin/bash

dir=$1

: ${dir:=/home/git/repositories/pub}

[ -n "${dir#/}" ] && dir=${dir%/}

val=$(ls $dir)

yc-git-manage.sh --base=$dir --pull="$(echo $val)"
