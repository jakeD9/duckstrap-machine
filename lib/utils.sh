#!/usr/bin/env bash

# ----------------------------
# Colors
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ----------------------------
# OS detection
# ----------------------------

OS="$(uname -s)"

is_mac() {
  [[ "$OS" == "Darwin" ]]
}

is_linux() {
  [[ "$OS" == "Linux" ]]
}

# ----------------------------
# Logging helpers
# ----------------------------
info() {
  echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}