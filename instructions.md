# homelab-bootstrap
a collection of scripts to bootstrap my homelab


i am building a homelab setup running on ubuntu server 24 LTS

i want to setup a script that i can run that will bootstrap the server with all items i need to have my homelab ready to run a kubernetes cluster, pointed at a repo in my github.

it will use gitops with flux, authenticate with github to read from my github container registry and update containers

the cluster itself is going to run in a proxmox VM, with a DNS sidecar running pihole in another proxmox VM

i also want this server to have any helpful tooling for when i ssh into it to edit files, etc

i need a script that will:

install zsh/ohmyzsh (and make use of my config setup here)
install github cli and authenticate with my github
install neovim
install proxmox
install k3s
install flux, optionally bootstrap it

and some ohter tooling that would be helpful to have on the server, since it's very barebones currently. 

i want to re-use what i can in this repo already, but with a separate script/path to run a bootstrap_server.sh script or bootstrap.sh --servermode. there should be a separation of concerns for server vs dev machine in the repo structure.

we can assume that ssh is already setup since i will be cloning this repo from my repositories

feel free to make suggestions for other tooling that might be helpful, and walk me through why you chose what you did. please critique this plan and provide constructive feedback to improve the process without introducing a ton more complexity