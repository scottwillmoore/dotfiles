# file: .bashrc
# author: scott moore

# TODO: use vim as PAGER.

# stop executing if this is not an interactive session.
[[ $- != *i* ]] && return

# enable colour support of ls and other tools.
if [ -x /usr/bin/dircolors ]; then
	# load custom dircolors definitions.
	[ -e $HOME/.dir_colors ] && eval $(dircolors $HOME/.dir_colors)

	# enable the use of colors.
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# ______________________________________________________________________________
# configuration

# set completion to be case insensitive.
bind 'set completion-ignore-case on'

# treat underscores and hypthens as equivelent during completion.
bind 'set completion-map-case on'

# show all possible matches for ambiguous patterns at the first keypress, rather than the second.
bind 'set show-all-if-ambiguous on'

# immediately add a trailing slash when autocompleting symlinks to directories.
bind 'set mark-symlinked-directories on'

# perform history expansion on the current line when inserting a space.
bind Space:magic-space

# append to the history file, don't overwrite it.
shopt -s histappend

# save multiple-line commands in the same history entry.
shopt -s cmdhist

# use a large history, does not appear to have negative performance impacts.
HISTSIZE=10000
HISTFILESIZE=10000

# avoid duplicate entries.
HISTCONTROL='erasedups:ignoreboth'

# don't record common commands.
HISTIGNORE="ls:exit:history"

# show history with the following timestamp format.
HISTTIMEFORMAT='%F %T  '

# use a custom prompt, which is defined at the bottom of this file.
PROMPT_COMMAND="build_prompt; set_title"

# ______________________________________________________________________________
# variables

# set default pager.
export PAGER=less

# set default text editor.
export EDITOR=vim
export VISUAL=vim

# set default web browser.
export BROWSER=google-chrome-stable


# ______________________________________________________________________________
# aliases

# reset will replace the current instance with a new instance.
alias reset="exec $BASH"

# reload will preserve the current instance, but does not completely reset instance state.
alias reload="source $HOME/.bashrc"

# open files and folders from the command line; also hide resulting logs and error messages.
alias open='xdg-open &>/dev/null'

# host the current directory as static files on port 8000.
alias webshare='python3 -m http.server'


# ______________________________________________________________________________
# functions

# TODO: refine the show_todo tracker.
show_todo() {
	local dotfiles=('.bashrc' '.vimrc' '.tmux.conf')
	grep --color=always -n "TODO:" "${dotfiles[@]}" |\
		grep --color=always -v 'grep --color=always' |\
		column -t -s ':' -o '    '
}

# bootstrap man in order to color man pages.
man() {
	LESS_TERMCAP_me=$(tput sgr0) \
	LESS_TERMCAP_md=$(tput bold) \
	LESS_TERMCAP_so=$(tput smso) \
	LESS_TERMCAP_se=$(tput rmso; tput sgr0) \
	LESS_TERMCAP_us=$(tput smul) \
	LESS_TERMCAP_ue=$(tput rmul; tput sgr0) \
	command man "$@"
}

# truncate the current path, by shortening parent directories to single characters.
get_short_path() {
	echo -n "$(pwd |sed -e "s!$HOME!~!" | sed -re 's!([^/])[^/]+/!\1/!g')"
}

# parse git information to embed into custom prompt.
# WARN: this code is untested, and was created by myself as a challenge! there
# may be better solutons out there...
get_git_info() {
	# store current git state as easy-to-parse format.
	local git_status="$(git status --branch --porcelain=v1 2>/dev/null)"

	# check we are in git repository.
	if [ -n "$git_status" ]; then
		# NOTE: welcome to the regex of pain. sometimes doing it your own way is harder...

		# perl regex used to capture current branch and remote.
		local parse_header_perl='print if s/^## ((?:(?!\.\.\.).)+)(?:(?:\.\.\.)(.+))?$/\@/g'
		
		# substitute the correct capture into the perl regex and evaluate to get branch and remote.
		local git_branch=$(perl -ne "${parse_header_perl/@/1}" <<< "$git_status")
		local git_remote=$(perl -ne "${parse_header_perl/@/2}" <<< "$git_status")

		# parse the remaining git state into variables.
		local git_staged=$(grep -Ec '^[MADRC]' <<< "$git_status")
		local git_unstaged=$(grep -Ec '^ [MD]' <<< "$git_status")
		local git_untracked=$(grep -Ec '^\?\?' <<< "$git_status")

		# construct the git information of the prompt.
		local git_info="$git_branch"
		# [ -n $git_remote ] && git_info+="..$git_remote"
		[ $git_untracked != 0 ] && git_info+=''
		[ $git_unstaged != 0 ] || [ $git_staged != 0 ] && git_info+='*'
		echo "$git_info"
	fi
}

set_title() {
	# create empty title.
	local title=''

	# if connected using SSH, display hostname.
	if [ "$SSH_CONNECTION" ]; then
		title+="@${HOSTNAME} "
	fi

	# display the truncated current path.
	title+="$(get_short_path)"

	# allocate the custom title if supported by terminal.
	if [ "$(tput tsl)" ]; then
		echo -n "$(tput tsl)${title}$(tput fsl)"
	fi
}

# build a customised bash prompt.
build_prompt() {
	# store previous exit codes, so that user can be alerted to errors.
	# this needs to be the first command executed.
	local exit_code=$?

	# define common text rendering paramenters and colours.
	local reset="\[$(tput sgr0)\]"
	local bold="\[$(tput bold)\]"
	local black="\[$(tput setaf 0)\]"
	local red="\[$(tput setaf 1)\]"
	local green="\[$(tput setaf 2)\]"
	local yellow="\[$(tput setaf 3)\]"
	local blue="\[$(tput setaf 4)\]"
	local magenta="\[$(tput setaf 5)\]"
	local cyan="\[$(tput setaf 6)\]"
	local white="\[$(tput setaf 7)\]"

	# create empty prompt.
	local prompt=''

	# display current logged in user.
	# prompt+="${cyan}${USER} "

	# if connected using SSH, display hostname.
	if [ "$SSH_CONNECTION" ]; then
		prompt+="${yellow}@${HOSTNAME} "
	fi

	# display the truncated current path.
	prompt+="${cyan}$(get_short_path) "

	# display git information, if it exists, and is not the dotfiles repository.
	local git_info="$(get_git_info)"
    if [ "$git_info" ] && [ $(git rev-parse --show-toplevel) != "$HOME" ]; then
		prompt+="${green}${git_info} "
	fi

	# if last program exited with an error, indicate this with red.
	if [ $exit_code == 0 ]; then
		prompt+="${white}"
	else
		prompt+="${red}"
	fi
	prompt+="$ "

	# reset the text back to white.
	prompt+="${reset}"

	# allocate the custom prompt.
	PS1="$prompt"
}
