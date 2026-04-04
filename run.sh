#!/usr/bin/env bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

#############################################
# 1. Install stuff to get everything else
#############################################
info "Getting the basics first..."

install curl
install git
