typeset -gAH WEAKLINE_VCS_ICONS
WEAKLINE_VCS_ICONS=(
	UNTRACKED		"\uE16C"
	UNSTAGED		"\uE17C"
	STAGED			"\uE168"
	STASH			"\uE133"
	INCOMING		"\uE131"
	OUTGOING		"\uE132"
	BRANCH			"\uE220"
	GIT				"\uE20E"
	SVN				"(svn)"
	HG				"\uE1C3"
)
WEAKLINE_VCS_BACKGROUND=green
WEAKLINE_VCS_CHANGED_BACKGROUND=yellow
WEAKLINE_VCS_ERROR_BACKGROUND=red
WEAKLINE_VCS_FOREGROUND=black

autoload -Uz add-zsh-hook
autoload -Uz vcs_info

function _weakline_vcs_precmd() { LANG=C vcs_info }
add-zsh-hook precmd _weakline_vcs_precmd

# Use 3 formats for:
# $vcs_info_msg_0_ ordinary messages
# $vcs_info_msg_1_ warning messages
# $vcs_info_msg_2_ error messages
zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:*' formats "%s ${WEAKLINE_VCS_ICONS[BRANCH]} %b%m" "%u%c"
zstyle ':vcs_info:*' actionformats "%s ${WEAKLINE_VCS_ICONS[BRANCH]} %b%m" "%u%c" "%a"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr " ${WEAKLINE_VCS_ICONS[STAGED]}"
zstyle ':vcs_info:*' unstagedstr " ${WEAKLINE_VCS_ICONS[UNSTAGED]}"
zstyle ':vcs_info:git+set-message:*' hooks \
									 hook-begin \
									 git-hook-begin \
									 git-status \
									 git-stash
zstyle ':vcs_info:svn+set-message:*' hooks \
									 hook-begin
zstyle ':vcs_info:hg+set-message:*' hooks \
									hook-begin

function +vi-hook-begin() {
	if [[ "${hook_com[vcs]}" == "git" ]]; then
		hook_com[vcs]=$WEAKLINE_VCS_ICONS[GIT]
	elif [[ "${hook_com[vcs]}" == "svn" ]]; then
		hook_com[vcs]=$WEAKLINE_VCS_ICONS[SVN]
	elif [[ "${hook_com[vcs]}" == "hg" ]]; then
		hook_com[vcs]=$WEAKLINE_VCS_ICONS[HG]
	fi
}

function +vi-git-hook-begin() {
	# Check if its not inside the working tree
	if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
		return 1
	fi
	
	return 0
}

function +vi-git-status() {
	local ahead behind branch git_status
	
	git_status=$(git status --porcelain --branch 2> /dev/null)
	ahead=${git_status#*\[ahead }
	[[ "${ahead:0:1}" = <-> ]] && ahead=${ahead/\]*/}
	behind=${git_status#*\[behind }
	[[ "${behind:0:1}" = <-> ]] && behind=${behind/\]*/}
	
	if echo $git_status | grep -E '^\?\?' > /dev/null 2>&1; then
		hook_com[misc]+=" $WEAKLINE_VCS_ICONS[UNTRACKED]"
	fi
	
	[[ "$behind" = <-> ]] && hook_com[misc]+=" $WEAKLINE_VCS_ICONS[INCOMING]$behind"
	[[ "$ahead" = <-> ]] && hook_com[misc]+=" $WEAKLINE_VCS_ICONS[OUTGOING]$ahead"
	
	return 0
}

function +vi-git-stash() {
	if [[ -s $(git rev-parse --git-dir)/refs/stash ]] ; then
		hook_com[misc]+=" $WEAKLINE_VCS_ICONS[STASH]$(git stash list 2>/dev/null | wc -l)"
	fi
}

function weakline_vcs() {
	if [[ -z "${vcs_info_msg_0_}" ]]; then return; fi
	
	local background=$WEAKLINE_VCS_BACKGROUND
	local message=$vcs_info_msg_0_
	
	if [[ -n "${vcs_info_msg_1_}" ]]; then
		background=$WEAKLINE_VCS_CHANGED_BACKGROUND
		message+=$vcs_info_msg_1_
	fi
	
	if [[ -n "${vcs_info_msg_2_}" ]]; then
		background=$WEAKLINE_VCS_ERROR_BACKGROUND
		message+=" $vcs_info_msg_2_"
	fi
	
	weakline_write_segment "$message" $background $WEAKLINE_VCS_FOREGROUND
}
