# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=4000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/seinvan/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# ohmyzsh/powerlevel10k
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# PATH
export PATH="$HOME/.local/kitty.app/bin:$HOME/.local/bin:$PATH"

# Print the first public SSH key found in the default ~/.ssh location.
alias show-ssh-pubkey='found=0; for key in "$HOME"/.ssh/*.pub; do if [ -f "$key" ]; then cat "$key"; found=1; break; fi; done; [ "$found" -eq 1 ] || echo "No public SSH key found in ~/.ssh"'
