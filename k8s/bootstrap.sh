#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$REPO_ROOT/utils.sh"

K3S_CHANNEL="${K3S_CHANNEL:-stable}"
K3S_ROLE="${K3S_ROLE:-server}"

pick_role() {
  local role_input

  read -rp "Install this node as a k3s server or agent? [server/agent] " role_input

  case "${role_input:-$K3S_ROLE}" in
    server|agent)
      K3S_ROLE="${role_input:-$K3S_ROLE}"
      ;;
    *)
      error "Expected 'server' or 'agent'"
      exit 1
      ;;
  esac
}

install_k8s_prereqs() {
  info "Installing Kubernetes node prerequisites"
  install_packages \
    curl \
    jq \
    ca-certificates \
    apt-transport-https \
    qemu-guest-agent
}

install_k3s_server() {
  if command_exists k3s; then
    success "k3s server already installed"
    return 0
  fi

  info "Installing k3s server (${K3S_CHANNEL} channel)"
  curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL="$K3S_CHANNEL" sh -
}

install_k3s_agent() {
  local server_url
  local node_token

  if command_exists k3s-agent; then
    success "k3s agent already installed"
    return 0
  fi

  read -rp "k3s server URL (for example: https://10.0.0.10:6443): " server_url
  read -rsp "k3s node token: " node_token
  echo

  info "Installing k3s agent (${K3S_CHANNEL} channel)"
  curl -sfL https://get.k3s.io | K3S_URL="$server_url" K3S_TOKEN="$node_token" INSTALL_K3S_CHANNEL="$K3S_CHANNEL" sh -
}

install_flux() {
  if command_exists flux; then
    success "Flux CLI already installed"
    return 0
  fi

  info "Installing Flux CLI"
  curl -s https://fluxcd.io/install.sh | sudo bash
}

bootstrap_flux() {
  local gitops_repo
  local gitops_branch
  local cluster_path

  if [[ "$K3S_ROLE" != "server" ]]; then
    info "Skipping Flux bootstrap on agent nodes"
    return 0
  fi

  if ! prompt_yes_no "Bootstrap Flux against your cluster repository now?" "N"; then
    info "Skipping Flux bootstrap"
    return 0
  fi

  install_if_missing gh

  if ! gh auth status >/dev/null 2>&1; then
    info "Flux bootstrap against GitHub needs GitHub CLI auth or equivalent token access"
    gh auth login
  fi

  read -rp "GitHub owner/repo (for example: seinvan/homelab-gitops): " gitops_repo
  read -rp "Git branch to bootstrap from [main] " gitops_branch
  read -rp "Cluster path in the repo [clusters/homelab] " cluster_path

  gitops_branch="${gitops_branch:-main}"
  cluster_path="${cluster_path:-clusters/homelab}"

  flux bootstrap github \
    --owner "${gitops_repo%/*}" \
    --repository "${gitops_repo#*/}" \
    --branch "$gitops_branch" \
    --path "$cluster_path" \
    --personal
}

print_notes() {
  cat <<EOF

k3s node bootstrap notes:
- This node was configured as a k3s ${K3S_ROLE}.
- Flux only needs to be bootstrapped from a server/control-plane node.
- kubeconfig for a server node will be at /etc/rancher/k3s/k3s.yaml.

GitHub access guidance:
- The VM does not need your personal SSH key just to run Flux.
- Flux bootstrap uses GitHub auth when you run it, then creates the repo access your cluster needs.
- Give the VM GitHub SSH setup only if you want to do manual git or gh work inside the VM later.
EOF
}

info "Bootstrapping k3s node..."

require_linux

if [[ "$PM" != "apt" ]]; then
  error "k3s bootstrap currently expects Ubuntu/Debian with apt"
  exit 1
fi

pick_role
install_k8s_prereqs

if [[ "$K3S_ROLE" == "server" ]]; then
  install_k3s_server
  install_flux
else
  install_k3s_agent
fi

bootstrap_flux
print_notes

success "k3s node bootstrap complete"
