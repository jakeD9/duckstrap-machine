#!/usr/bin/env bash

set -e

source "$REPO_ROOT/utils/utils.sh"

#############################################
# 1. Install stuff to get everything else
#############################################
info "Getting the basics first..."

install curl
install git
