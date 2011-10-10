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
# parse command-line options
#
# Export symbols
#	Index	Name			Type
#	1		yc_getopt		function
#

[ "$_d0bfca281b294b7ce0c267a552b5f697" = "d0bfca281b294b7ce0c267a552b5f697" ] && return 0
_d0bfca281b294b7ce0c267a552b5f697=d0bfca281b294b7ce0c267a552b5f697

# NAME
#	yc_getopt - parse command-line options
#
# SYNOPSIS
#	yc_getopt "[prefix-option-name][,suffix-option-name]" "callback-warn" "[long-name-option1][,short-name-option1][,:[:]]" ... [-- arguments]
#
# DESCRIPTION
#	yc_getopt parses the command-line arguments. "prefix-option-name" and "suffix-option-name" are the prefix and suffix of option-name for each option.
#	"callback-warn" is the callback routine for warning information. "long-name-option1[,short-name-option1][,required|optional]" is option information of
#	an option. Information list of name-option is ended with double-dash(--). After double-dash is command-line arguments, atnd command-line arguments are
#	ended with double-dash too.
#
#	Like as the string "prefix-variable-name" and "suffix-variable-name" hinted, them are the prefix and suffix of an option-name. For an non-empty prefix,
#	an underscore('_') would be appended. For an non-empty prefix, an underscore would be insert at the beginning.
#
#	"callback-warn" defines the callback-routine of warning information. The non-zero return value of the routine means yc_getopt() returns non-zero value
#	immediately without any valid report. yc_getopt() ignores all warning for an empty "callback-warn".
#
#	"long-name-option1[,short-name-option1][,required|optional]" designates the long-name of an option, the acronym of an option, and the value attributes
#	of an option. The list of option's information is ended with double dash.  An optional suffix one colon indicates the option has a required value, two
#	colons indicate the option has an optional value. Without colon means the option doesn't has a value.
#
#	"option1" is an command-line argument. An double dash forces an end-of option scanning. Otherwise, the all remainder arguments would be parsed.
#
# RETURN VALUE
#	On success, zero is returned. Otherwise, non-zero is returned, and ycsh_string_err is set appropriately.
#
# EXAMPLE
#	1.
#		call: yc_getopt "" "" "user,u,:" "password,p,::" "entrypt-file,e" -- --user=yanyg -p 'trivial password' -e
#		result: returns zero and prints out: user='yanyg' password='trivaial password' entrypt_file=''
#
#	2.
#		call: yc_getopt "arg,real" "" "user,u,:" "password,p,::" "entrypt-file,e" -- -ep --user yanyg
#		result: returns zero and prints out: arg_user_real='yanyg' arg_password_real='' arg_entrypt_file_real=''
#
#	3.
#		[ First we assume that arg_warn routine definition like as: arg_warn() { return 1; } ]
#		call: yc_getopt "" "arg_warn" "user,u,:" "password,p,::" "entrypt-file,e" -- -e -p --user
#		result: returns 1 and print none.
#

# enviroment-value
: ${YCSH_PATH_INSTALL:=/usr/local/bin/ycsh}
: ${YCSH_PATH_LIB:=$YCSH_PATH_INSTALL/lib}

# import
. $YCSH_PATH_LIB/lib_config.sh

yc_source lib_ctype.sh lib_io.sh lib_var.sh

# usage: yc_getopt "[prefix][,suffix]" "callback-warn" "[long-opt1][,short-opt],[,:[:]]" ... [ -- arguments ]
yc_getopt()
{
	[ $# -gt 2 ] || return $EPARAM

	local prefix=${1%%,*} suffix=${1##*,} callback_warn=$2; shift; shift

	# preprocess prefix, suffix
	if [ -n "$prefix" ]; then
		[ "$prefix" = "$suffix" ] && suffix=""
		prefix=$(yc_var_gen "$prefix")
		[ -n "${prefix##*_}" ] && prefix="${prefix}_"
	fi
	if [ -n "$suffix" ]; then
		suffix=$(yc_var_gen "$suffix")
		[ -n "${suffix%%_*}" ] && suffix="_${suffix}"
	fi
	if [ -z "$callback_warn" ]; then
		callback_warn=true
	fi

	local lopt_array="" sopt_array="" val_array="" idx_array=0

	__yc_getopt_error()
	{
		if [ -n "$callback_warn" ]; then
			$callback_warn "$@" || yc_exit $EINVAL
		else
			yc_exit $EINVAL "$@"
		fi
	}

	while [ "$#" -ne "0" ]
	do
		local opt=$1; shift

		[ -z "$opt" ] && continue
		[ "$opt" = "--" ] && break

		# updates long-option, short-option
		local lopt=${opt%%,*} sopt=${opt#*,} val="" invalid=""

		# the option-item have no comma ?
		[ "$lopt" = "$sopt" ] && sopt=""

		if [ -n "$sopt" ]; then
			# separate val, sopt
			val=${sopt##*,}
			sopt=${sopt%%,*}
			[ -n "${sopt##*[!:]*}" ] && sopt=""
			[ "$val" = "$sopt" ] && val=""

			if [ "${#val}" -gt "2" ] || [ -n "${val}" -a -z "${val##*[!:]*}" ]; then
				yc_exit 1 "option '$opt' has an invalid value: '$val' (valid value is [:[:]])"
			fi

			if [ -n "${sopt#[A-Za-z0-9]}" ]; then
				yc_exit 1 "option '$opt' has an invalid short-name: '$sopt' (valid short-name of an option is a single-character)"
			fi
		fi

		lopt_array[$idx_array]=$(yc_var_gen "$(echo "$lopt"|tr = _)")
		sopt_array[$idx_array]="$sopt"
		val_array[$idx_array]="$val"
		((++idx_array))
	done

	# convert to readonly
	local -r lopt_array sopt_array val_array
	local -r -i max_idx=$idx_array

	__yc_getopt_lopt()
	{
		[ $# -lt 1 ] && return $EINVAL

		local name=${1%%=*} value=${1#*=}

		[ "$name" = "$value" ] && value=""
		name=$(yc_var_gen $name)

		local idx real_name=$prefix$name$suffix real_value=""
		for((idx=0; idx<max_idx; ++idx))
		do
			if [ "$name" = "${lopt_array[$idx]}" ]; then
				case "${val_array[$idx]}" in
					":"|"::")
						{
							if [ -n "$value" ]; then
								real_value="$value"
							elif [ -n "$2" -a -n "${2##-*}" ]; then
								real_value="$2"
								need_shift="yes"
							else
								[ ":" = "${val_array[$idx]}" ] && __yc_getopt_error "argument '--$name' requires a value"
								real_value=""
							fi
						}
						;;
					"")
						{
							[ -n "$value" ] && __yc_getopt_error "argument '--$name' doesn't require a value"
							real_value="$value"
						}
						;;
					*)
						# cannot get here except a program bug exists.
						yc_exit 1 "option value format error ?"
						;;
				esac

				# report
				echo "$real_name='$real_value'"
				break
			fi
		done
	}

	__yc_getopt_sopt()
	{
		[ $# -lt 1 ] && return $EINVAL

		local opt=$1
		local name=${1%%=*} value=${1#*=}
		local real_name="" real_value=""

		[ "$name" = "$value" ] && value=""

		local opt_idx
		for ((opt_idx=0; opt_idx<${#opt}; ++opt_idx))
		do
			local idx cur=${opt:$opt_idx:1}
			for((idx=0; idx<max_idx; ++idx))
			do
				if [ "$cur" = "${sopt_array[$idx]}" ]; then
					case "${val_array[$idx]}" in
						":"|"::")
							{
								((++opt_idx))
								real_value=${opt:$opt_idx}

								if [ -n "$real_value" ]; then
									opt_idx=${#opt} # all left treats as value
								elif [ -n "$2" -a -n "${2##-*}" ]; then
									real_value="$2"
									need_shift="yes"
								else
									[ ":" = "${val_array[$idx]}" ] && __yc_getopt_error "argument '-$cur' requires a value"
									real_value=""
								fi
							}
							;;
						"")
							{
								real_value=""
							}
							;;
						*)
							yc_exit 1 "short-option value format error ??"
							;;
					esac

					# report
					if [ -n "${lopt_array[$idx]}" ]; then
						real_name=$prefix${lopt_array[$idx]}$suffix
					else
						real_name=$prefix$cur$suffix
					fi

					echo "$real_name='$real_value'"
					break
				fi
			done

			# unknown option ?
			[ $idx -eq $max_idx ] && __yc_getopt_error "invalid option: '-$cur'"
		done
	}

	while [ $# -ne 0 ]
	do
		local opt=$1

		shift; [ -z "$opt" ] && continue

		# do work
		local need_shift=no
		case "$opt" in
			--)
				break	# end 
				;;
			--*)
				__yc_getopt_lopt "${opt#--}" "$1"
				;;
			-*)
				__yc_getopt_sopt "${opt#-}" "$1"
				;;
			*)
				__yc_getopt_error "invalid option: '$opt'"
				;;
		esac

		[ "yes" = "$need_shift" ] && shift
	done
}
