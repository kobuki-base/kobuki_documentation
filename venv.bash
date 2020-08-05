#!/bin/bash

# Script for setting up an environment to build the documentation.

NAME=kobuki_documentation

##############################################################################
# Directories
##############################################################################

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VENV_DIR=${SRC_DIR}/.venv

##############################################################################
# Colours
##############################################################################

BOLD="\e[1m"
CYAN="\e[36m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

padded_message () {
  line="........................................"
  printf "%s %s${2}\n" ${1} "${line:${#1}}"
}

pretty_header () {
  echo -e "${BOLD}${1}${RESET}"
}
pretty_print () {
  echo -e "${GREEN}${1}${RESET}"
}
pretty_warning () {
  echo -e "${YELLOW}${1}${RESET}"
}
pretty_error () {
  echo -e "${RED}${1}${RESET}"
}


##############################################################################
# Methods
##############################################################################

install_package ()
{
  PACKAGE_NAME=$1
  dpkg -s ${PACKAGE_NAME} > /dev/null
  if [ $? -ne 0 ]; then
    sudo apt-get -q -y install ${PACKAGE_NAME} > /dev/null
  else
    pretty_print "  $(padded_message ${PACKAGE_NAME} "found")"
    return 0
  fi
  if [ $? -ne 0 ]; then
    pretty_error "  $(padded_message ${PACKAGE_NAME} "failed")"
    return 1
  fi
  pretty_warning "  $(padded_message ${PACKAGE_NAME} "installed")"
  return 0
}

##############################################################################


#############################
# Checks
#############################

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && SOURCED=1
if [ -z "$SOURCED" ]; then
  pretty_error "This script needs to be sourced, i.e. source './setup.bash', not './setup.bash'"
  exit 1
fi

#############################
# System Dependencies
#############################

# install_package kcachegrind || return

#############################
# Virtual Env
#############################

pretty_header "Virtual Environment"

if [ -x ${VENV_DIR}/bin/pip3 ]; then
    pretty_print "  $(padded_message "virtual_environment" "found [${VENV_DIR}]")"
else
    python3 -m venv ${VENV_DIR}
    pretty_warning "  $(padded_message "virtual_environment" "created [${VENV_DIR}]")"
fi

source ${VENV_DIR}/bin/activate

#############################
# Pypi Dependencies
#############################

pretty_header "PyPi Dependencies"

# restrict versions because of bleeding edge incompatibilities on rtd
pip install -r doc/requirements.txt

# NB: this automagically nabs install_requires
python setup.py develop

echo ""
echo "Leave the virtual environment with 'deactivate'"
echo ""
echo "I'm grooty, you should be too."
echo ""
