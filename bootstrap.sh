#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

run_setup() {
  local script_path="$1"

  info "Running $(basename "$(dirname "$script_path")") setup..."
  bash "$script_path"
}

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
install curl
install git

#############################################
# 2. Run setup scripts in dependency order
#############################################

run_setup "$SCRIPT_DIR/shell/setup.sh"
run_setup "$SCRIPT_DIR/dev/setup.sh"
run_setup "$SCRIPT_DIR/vscode/setup.sh"
run_setup "$SCRIPT_DIR/git/setup.sh"

success "Bootstrap complete"
