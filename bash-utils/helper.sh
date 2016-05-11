#!/bin/bash

#
# Script taken from: http://natelandau.com/bash-scripting-utilities/
#

#
# Set Colors
#

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)

#
# Headers and  Logging
#

helper_show_header_big() {
    printf "\n${bold}${purple}=============================================${reset}"
    printf "\n${bold}${purple}   %s${reset}" "$@"
    printf "\n${bold}${purple}=============================================${reset}\n"
}

helper_show_header() {
    printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}
helper_show_notice() {
    printf "${blue}%s${reset}\n" "$@"
}
helper_show_success() {
    printf "${green}%s${reset}\n" "$@"
}
helper_show_error() {
    printf "${red}%s${reset}\n" "$@"
}
helper_show_warning() {
    printf "${tan}%s${reset}\n" "$@"
}
helper_show_underline() {
    printf "${underline}${bold}%s${reset}\n" "$@"
}
helper_show_bold() {
    printf "${bold}%s${reset}\n" "$@"
}
helper_show_note() {
    printf " ${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}

helper_show_partial_message() {
    printf "%s" "$@"
}
helper_show_partial_notice() {
    printf "${blue}%s${reset}" "$@"
}
helper_show_partial_warning() {
    printf "${tan}%s${reset}" "$@"
}
helper_show_message() {
    printf "%s\n" "$@"
}

#
# USAGE FOR SEEKING CONFIRMATION
# seek_confirmation "Ask a question"
# Credt: https://github.com/kevva/dotfiles
#
# if is_confirmed; then
#   some action
# else
#   some other action
# fi
#

helper_seek_confirmation() {
  printf "\n${blue}$@${reset} (y/n) "
  read -n 1
  printf "\n"
}

# underlined
helper_seek_confirmation_head() {
  printf "\n${underline}${bold}$@${reset}"
  read -p "${underline}${bold} (y/n)${reset} " -n 1
  printf "\n"
}

# Test whether the result of an 'ask' is a confirmation
helper_is_confirmed() {
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1
}

# Provide the message and the example
helper_get_user_data() {
    unset REPLY
    printf "\n${blue}$@${reset}: "
    while read && [[ -z "${REPLY}" ]] ; do
        helper_show_error "Not valid data provided!"
        printf "\n${blue}$@${reset}: "
    done
    return 1
}

# cmn_replace_in_files search replace file
#
# Replaces given string 'search' with 'replace' in given files.
#
# Important: The replacement is done in-place. Thus, it overwrites the given
# files, and no backup files are created.
#
# Note that this function is intended to be used to replace fixed strings; i.e.,
# it does not interpret regular expressions. It was written to replace simple
# placeholders in sample configuration files (you could say very poor man's
# templating engine).
#
# This functions expects given string 'search' to be found in all the files;
# thus, it expects to replace that string in all files. If a given file misses
# that string, a warning is issued by calling `cmn_echo_warn`. Furthermore,
# if a given file does not exist, a warning is issued as well.
#
# To replace the string, perl is used. Pattern metacharacters are quoted
# (disabled). The search is a global one; thus, all matches are replaced, and
# not just the first one.
#
# Example:
# cmn_replace_in_files placeholder replacement file1.txt
#
function helper_replace_in_files {
    local search=${1}
    local replace=${2}
    local file=${3}

    if [[ -e "${file}" ]]; then
      if ( grep --fixed-strings --quiet "${search}" "${file}" ); then
        perl -pi -e "s/\Q${search}/${replace}/g" "${file}"
      else
        return 1
        #cmn_echo_warn "Could not find search string '${search}' (thus, cannot replace with '${replace}') in file: ${file}"
      fi
    fi
    return 0
}

#
#
function helper_replace_in_file_regexp() {
    sed -i "s|${1}|${2}|g" ${3}
    return $?
}

function helper_file_exists() {
    if [ -f ${1} ] ; then
        return 0
    fi
    return 1
}

function helper_directory_exists() {
    if [ -d ${1} ] ; then
        return 0
    fi
    return 1
}

#
# Test whether a command exists
# $1 = cmd to test
# Usage:
# if type_exists 'git'; then
#   some action
# else
#   some other action
# fi
#

function helper_type_exists() {
if [ $(type -P $1) ]; then
  return 0
fi
  return 1
}

function heplper_running_as_root() {
  if [[ ${EUID} -ne 0 ]]; then
    return 0;
  fi
  return 1;
}

# Verify that the parameter passed is an IP Address:
function helper_is_valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Usage: helper_apache_get_mirror "lucene/solr/4.10.3/solr-4.10.3.zip"
#  Example:  URL=$(helper_apache_get_mirror "lucene/solr/4.10.3/solr-4.10.3.zip")
function helper_apache_get_mirror () {
    APACHE_CLOSER_CGI="http://www.apache.org/dyn/closer.cgi"
    APACHE_CLOSER_MIRROR=$(curl -s "${APACHE_CLOSER_CGI}?path=${1}&asjson=1" |  awk '/preferred/{print $2}' | sed 's/"//g')
    echo "Closer apache mirror: $APACHE_CLOSER_MIRROR" >&2
    APACHE_MIRROR=${APACHE_MIRROR:-$APACHE_CLOSER_MIRROR}
    echo "Selected apache mirror: $APACHE_MIRROR" >&2
    echo "$APACHE_MIRROR" | sed "s|\$|${1}|"
}

