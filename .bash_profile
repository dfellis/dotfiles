# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

# The various escape codes that we can use to color our prompt.
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"
COLOR_NONE="\[\e[0m\]"

# Detect whether the current directory is a git repository.
function is_git_repository {
	git branch > /dev/null 2>&1
}

# Determine the branch/state information for this git repository.
function set_git_branch {
	# Capture the output of the "git status" command.
	git_status="$(git status 2> /dev/null)"

	# Set color based on clean/staged/dirty.
	if [[ ${git_status} =~ "working tree clean" ]]; then
		state="${GREEN}"
	elif [[ ${git_status} =~ "Changes to be committed" ]]; then
		state="${YELLOW}"
	else
		state="${RED}"
	fi

	# Set arrow icon based on status against remote.
	remote_pattern="Your branch is (.*) '"
	if [[ ${git_status} =~ ${remote_pattern} ]]; then
		if [[ ${BASH_REMATCH[1]} == "ahead of" ]]; then
			remote="^"
    elif [[ ${BASH_REMATCH[1]} == "up to date with" ]]; then
      remote=""
		else
			remote="v"
		fi
	else
		remote=""
	fi
	diverge_pattern="Your branch and (.*) have diverged"
	if [[ ${git_status} =~ ${diverge_pattern} ]]; then
		remote="x"
	fi

	# Get the name of the branch.
	branch_pattern="^On branch ([^${IFS}]*)"
	if [[ ${git_status} =~ ${branch_pattern} ]]; then
		branch=${BASH_REMATCH[1]}
	fi

	# Set the final branch string.
	BRANCH="${state}(${branch})${remote}${COLOR_NONE}"
}

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol () {
	if test $1 -eq 0 ; then
		PROMPT_SYMBOL="\$"
	else
		PROMPT_SYMBOL="${RED}\$${COLOR_NONE}"
	fi
}

# Set the full bash prompt.
function set_bash_prompt () {
	# Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
	# return value of the last command.
	set_prompt_symbol $?

	# Set the BRANCH variable.
	if is_git_repository ; then
		set_git_branch
	else
		BRANCH=''
	fi

	# Set the bash prompt variable.
	PS1="${GREEN}\u@\h${COLOR_NONE}:${BLUE}\w${COLOR_NONE}${BRANCH}${PROMPT_SYMBOL} "
}
# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt

# Loosely based on commands from: https://unix.stackexchange.com/questions/104018/set-dynamic-window-title-based-on-command-input?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
function settitle() {
  if [ "$BASH_COMMAND" = "set_bash_prompt" ]; then
    git_status="$(git status 2> /dev/null)"
    branch_pattern="^On branch ([^${IFS}]*)"
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
      branch=${BASH_REMATCH[1]}
    fi
    echo -ne "\033]0;$(whoami)@$(hostname):${PWD/*\//}(${branch})\007"
  else
    echo -ne "\033]0;${BASH_COMMAND}\007"
  fi
}
trap 'settitle' DEBUG

unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

if [ "$TERM" == "xterm-256color" ]; then
    setxkbmap -option caps:swapescape
fi
