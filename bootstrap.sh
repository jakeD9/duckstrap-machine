#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

MODE="dev"

usage() {
  cat <<'EOF'
Usage:
  ./bootstrap.sh
  ./bootstrap.sh --dev
  ./bootstrap.sh --servermode
  ./bootstrap.sh --k8smode
  ./bootstrap.sh --help

Modes:
  --dev         Bootstrap a developer workstation (default)
  --servermode  Bootstrap a baseline Ubuntu homelab box
  --k8smode     Bootstrap a k3s node / GitOps VM
EOF
}

run_setup() {
  local script_path="$1"

  info "Running $(basename "$(dirname "$script_path")") setup..."
  bash "$script_path"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dev)
      MODE="dev"
      ;;
    --servermode)
      MODE="server"
      ;;
    --k8smode)
      MODE="k8s"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "$MODE" == "server" ]]; then
  info "Routing to server bootstrap mode..."
  exec bash "$SCRIPT_DIR/server/bootstrap.sh"
fi

if [[ "$MODE" == "k8s" ]]; then
  info "Routing to k3s node bootstrap mode..."
  exec bash "$SCRIPT_DIR/k8s/bootstrap.sh"
fi

cat <<'EOF'
                                                      ____
                                                     /    `.
                                                    /-----.|          ____
                                                ___/___.---`--.__.---'    `--.
                                  _______.-----'           __.--'             )
                              ,--'---.______________..----'(  __         __.-'
                                        `---.___,-.|(a (a) /-'  )___.---'
                                                `-.>------<__.-'
            ______                       _____..--'      //
    __.----'      `---._                `._.--._______.-'/))
,--'---.__              -_                  _.-(`-.____.'// \
          `-._            `---.________.---'    >\      /<   \
              \_             `--.___            \ \-__-/ /    \
                \_                  `----._______\ \  / /__    \
                  \                      /  |,-------'-'\  `-.__\
                   \                    (   ||            \      )
                    `\                   \  ||            /\    /
                      \                   >-||  @)    @) /\    /
                      \                  ((_||           \ \_.'|
                       \                    ||            `-'  |
                       \                    ||             /   |
                        \                   ||            (   '|
                        \                   ||  @)     @)  \   |
                         \                  ||              \  )
                          `\_               `|__         ____\ |
                             \_               | ``----'''     \|
                               \_              \    .--___    |)
                                 `-.__          \   |     \   |
                                      `----.___  \^/|      \/\|
                                               `--\ \-._  / | |
                                                   \ \  `'  \ \
                                            __...--'  )     (  `-._
                                           (_        /       `.    `-.__
                                             `--.__.'          `.       )
                                                                 `.__.-'
EOF


info "Bootstrapping machine..."

#############################################
# 1. Install base tools needed by the rest
#############################################

info "Getting the basics first..."
install_packages \
  curl \
  git

#############################################
# 2. Run setup scripts in dependency order
#############################################

run_setup "$SCRIPT_DIR/shell/setup.sh"
run_setup "$SCRIPT_DIR/dev/setup.sh"
run_setup "$SCRIPT_DIR/vscode/setup.sh"
run_setup "$SCRIPT_DIR/git/setup.sh"

success "Bootstrap complete"
