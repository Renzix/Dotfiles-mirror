# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Put your fun stuff here.

# Nice functions
# DEBUG=t
info() {
	[ -z "$DEBUG" ] ||
		printf "[%s]:$1\n" "$(date +'%D %T')";
}

if hash "exa" 2>/dev/null ; then
	info "Exa found"
	alias ls="exa"
	alias la="exa -a"
	alias ll='exa -lhF --color=always --group-directories-first --time-style=full-iso'
else
	info "Exa not found"
	alias l="ls --color=auto -h"
	alias la="ls -ah"
	alias ll='ls -lh'
fi


# Some nice keybindings and aliases
alias e="emacs -nw"
bind -m emacs -x '"\C-x\C-f":"emacs -nw ."'

# System Shutdown stuff
alias rb="sudo reboot"
alias sd="sudo shutdown -h now"

# git
alias gs="emacs -nw -f magit-status-only"
bind -m emacs -x '"\C-xg":"emacs -nw -f magit-status-only"'
alias gc="git commit"
alias gp="git push"

#Other
alias ht="htop"
alias kill-skyrim="env WINEPREFIX=~/.local/share/Steam/steamapps/compatdata/72850/pfx wineserver -k" # because im lazy only works on 1 cpu
alias kill-sse="env WINEPREFIX=~/.local/share/Steam/steamapps/compatdata/489830/pfx wineserver -k" # because im lazy only works on 1 cpu
alias vortex="WINEPREFIX=\"$HOME/Games/vortex\" /home/genzix/.local/share/lutris/runners/wine/tkg-4.0-x86_64/bin/wine /home/genzix/Games/vortex/drive_c/Program\ Files/Black\ Tree\ Gaming\ Ltd/Vortex/Vortex.exe"
alias kill-vortex="WINEPREFIX=\"$HOME/Games/vortex\" wineserver -k"


cb() {
	read -rt .1 input
	echo -e "\033]52;c;$(base64 <<< $input )\a"
}
pwdp() {
	PS1='\[\e[$([[ $? = 0 ]] && printf 32 || printf 31);1m\]\W\[\e[m\] '
}
usrp() {
	PS1='\[\e[$([[ $? = 0 ]] && printf 32 || printf 31);1m\]\$\[\e[m\] '
}
timep() {
	PS1='\[\e[$([[ $? = 0 ]] && printf 32 || printf 31);1m\]\A\[\e[m\] '
}
verp() {
	PS1='\[\e[$([[ $? = 0 ]] && printf 32 || printf 31);1m\]\v\[\e[m\] '
}
datep() {
	PS1='\[\e[$([[ $? = 0 ]] && printf 32 || printf 31);1m\]\d\[\e[m\] '
}

tw() {
	mpv "https://twitch.tv/$1"
}

# Random prompt from the ones above
#rand_prompt() {
#	prompts=('pwdp' 'timep' 'usrp' 'verp' 'datep')
#	RANDOM=$$$(date +%s)
#	rand=$[$RANDOM % ${#prompts[@]}]
#	${prompts[$rand]}
#}

#PROMPT_COMMAND=rand_prompt
pwdp

export NIX_AUTO_RUN=1
