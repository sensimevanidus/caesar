#!/usr/bin/env bash

# -- ABOUT THIS PROGRAM: ------------------------------------------------------
#
# Author:      Onur Yaman <onuryaman@gmail.com>
# Version:     0.1.0
# Description: Allows you to store your passwords in an encrypted way.
# Source:      N/A
#
# -- INSTRUCTIONS: ------------------------------------------------------------
#
# Execute:
#   $ chmod u+x caesar.sh && ./caesar.sh add <provider>
#   $ ./caesar.sh show <provider> <username>
#
# Options:
#   -h, --help    output program instructions
#   -v, --version output program version
#
# Alias:
#   alias caesar="bash ~/path/to/script/caesar.sh"
#
# Examples:
#   caesar add gmail
#   caesar show gmail onuryaman@gmail.com
#
# Important:
#   Note that you're gonna need a password that you shouldn't forget in order to
#   add/show data.
#   The credentials are stored in a file under ~/.caesar/passwd in an encrypted
#   way.
#   Only tested under MacOSX 10.14.6 with bash 3.2.
#
# -- CHANGELOG: ----------------------------------------------------------------
#
#   DESCRIPTION:
#   VERSION:     0.1.0
#   DATE:        2019-10-25
#   AUTHOR:      Onur Yaman <onuryaman@gmail.com>
#
# -- TODO & FIXES: -------------------------------------------------------------
#
#   - Use a stronger encryption algorithm to secure credentials file.
#   - Fix: If the password file is broken, it's not possible to recover it.
#   Make sure that it doesn't get broken when invalid password is provided.
#
# ------------------------------------------------------------------------------

VERSION="0.1.0"
PROGRAM="caesar"

caesar_help() {
cat <<EOT
--------------------------------------------------------------------------------
CAESAR - Store your passwords in an encrypted way.
--------------------------------------------------------------------------------

Usage: ./caesar.sh add <provider> && ./caesar.sh show <provider> <user>
Example: ./caesar add gmail && ./caesar show gmail onuryaman@gmail.com

Options:
  -h, --help    output program instructions
  -v, --version output program version

Important:
  Note that you're gonna need a password that you shouldn't forget in order to
  add/show data.
  The credentials are stored in a file under ~/.caesar/passwd in an encrypted
  way.

EOT
}

caesar_version() {
  echo "$VERSION"
}

PASS_DIR=~/.caesar
PASS_FILE=$PASS_DIR/passwd

caesar_init() {
  mkdir -p $PASS_DIR
}

caesar_add() {
  caesar_init

  if [ ! -f $PASS_FILE ]; then
    touch $PASS_FILE
    CONTENT=""
  else
    CONTENT=`cat $PASS_FILE | openssl enc -d -base64 -des -nosalt`
    CONTENT="$CONTENT\r\n"
  fi
  
  printf "Username: "
  read username
  printf "Password: "
  read -s password
  echo ""
  CONTENT="$CONTENT""$1:$username:$password"
  
  echo -e "$CONTENT" | openssl enc -base64 -des -nosalt -out $PASS_FILE
}

caesar_show() {
  caesar_init

  if [ -f $PASS_FILE ]; then
    if [ $# -eq 1 ]; then
      cat $PASS_FILE | openssl enc -d -base64 -des -nosalt | grep -F "$1"
    else
      cat $PASS_FILE | openssl enc -d -base64 -des -nosalt
    fi
  fi
}

LOCK_FILE=/tmp/${PROGRAM}.lock
if [ -f "$LOCK_FILE" ]; then
  echo "Caesar is already running"
  exit
fi
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

main() {

  if [ "${1}" = "-h" -o "${1}" = "--help" ]; then
    caesar_help
    exit
  elif [ "${1}" = "-v" -o "${1}" = "--version" ]; then
    caesar_version
    exit
  elif [ "${1}" = "-a" -o "${1}" = "add" ]; then
    caesar_add "$2"
    exit
  elif [ "${1}" = "-s" -o "${1}" = "show" ]; then
    caesar_show "$2"
    exit
  else
    caesar_help
    exit
  fi

}

main $*
