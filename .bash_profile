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

# Detect whether the current directory is a subversion repository.
function is_svn_repository {
	test -d .svn
}

# Determine the branch/state information for this git repository.
function set_git_branch {
	# Capture the output of the "git status" command.
	git_status="$(git status 2> /dev/null)"

	# Set color based on clean/staged/dirty.
	if [[ ${git_status} =~ "working directory clean" ]]; then
		state="${GREEN}"
	elif [[ ${git_status} =~ "Changes to be committed" ]]; then
		state="${YELLOW}"
	else
		state="${RED}"
	fi

	# Set arrow icon based on status against remote.
	remote_pattern="# Your branch is (.*) of"
	if [[ ${git_status} =~ ${remote_pattern} ]]; then
		if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
			remote="^"
		else
			remote="v"
		fi
	else
		remote=""
	fi
	diverge_pattern="# Your branch and (.*) have diverged"
	if [[ ${git_status} =~ ${diverge_pattern} ]]; then
		remote="x"
	fi

	# Get the name of the branch.
	branch_pattern="^# On branch ([^${IFS}]*)"
	if [[ ${git_status} =~ ${branch_pattern} ]]; then
		branch=${BASH_REMATCH[1]}
	fi

	# Set the final branch string.
	BRANCH="${state}(${branch})${remote}${COLOR_NONE}"
}

# Determine the branch information for this subversion repository. No support
# for svn status, since that needs to hit the remote repository.
function set_svn_branch {
	# Capture the output of the "git status" command.
	svn_info="$(svn info | egrep '^URL: ' 2> /dev/null)"

	# Get the name of the branch.
	branch_pattern="^URL: .*/(branches|tags)/([^/]+)"
	trunk_pattern="^URL: .*/trunk(/.*)?$"
	if [[ ${svn_info} =~ $branch_pattern ]]; then
		branch=${BASH_REMATCH[2]}
	elif [[ ${svn_info} =~ $trunk_pattern ]]; then
		branch='trunk'
	fi

	# Set the final branch string.
	BRANCH="(${branch})"
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
	elif is_svn_repository ; then
		set_svn_branch
	else
		BRANCH=''
	fi

	# Set the bash prompt variable.
	PS1="${GREEN}\u@\h${COLOR_NONE}:${BLUE}\w${COLOR_NONE}${BRANCH}${PROMPT_SYMBOL} "
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
esac

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

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	. /etc/bash_completion
fi

export WORKON_HOME=~/.virtualenvs  # Note that you can make WORKON_HOME whatever folder you like to keep your virtualenvs in.

alias ls="ls -G"

if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi
