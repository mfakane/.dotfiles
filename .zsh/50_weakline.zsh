typeset -gAH WEAKLINE_ICONS
WEAKLINE_ICONS=(
	LEFT_SEPARATOR	"\uE0B0"
	RIGHT_SEPARATOR	"\uE0B2"
	HOME			"\uE12C"
	HOME_SUB		"\uE18D"
	FOLDER			"\uE818"
	VCS_UNTRACKED	"\uE16C"
	VCS_UNSTAGED	"\uE17C"
	VCS_STAGED		"\uE168"
	VCS_STASH		"\uE133"
	VCS_INCOMING	"\uE131"
	VCS_OUTGOING	"\uE132"
	VCS_BRANCH		"\uE220"
	VCS_GIT			"\uE20E"
)
WEAKLINE_CONTEXT_BACKGROUND=black
WEAKLINE_CONTEXT_FOREGROUND=227
WEAKLINE_DIR_BACKGROUND=blue
WEAKLINE_DIR_FOREGROUND=white
WEAKLINE_VCS_BACKGROUND=green
WEAKLINE_VCS_CHANGED_BACKGROUND=yellow
WEAKLINE_VCS_FOREGROUND=black
WEAKLINE_INDICATOR_BACKGROUND=white
WEAKLINE_INDICATOR_FOREGROUND=black

WEAKLINE_LAST_BACKGROUND=""
WEAKLINE_DURATION=0

setopt prompt_subst
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

zstyle ':vcs_info:*' formats "${WEAKLINE_ICONS[VCS_BRANCH]} %b" "%u%c"
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " ${WEAKLINE_ICONS[VCS_STAGED]}"
zstyle ':vcs_info:git:*' unstagedstr " ${WEAKLINE_ICONS[VCS_UNSTAGED]}"

function _weakline_preexec() {
	WEAKLINE_TIMER=${timer:-$SECONDS}
}

function _weakline_precmd() {
	LANG=C vcs_info
	
	if [[ -n $WEAKLINE_TIMER ]]; then
		WEAKLINE_DURATION=$(($SECONDS - $WEAKLINE_TIMER))
		unset WEAKLINE_TIMER
	else
		WEAKLINE_DURATION=0
	fi
}

add-zsh-hook preexec _weakline_preexec
add-zsh-hook precmd _weakline_precmd

function weakline_write_segment() {
	if ! [[ -z $WEAKLINE_LAST_BACKGROUND ]]; then
		echo -n "%K{$2}%F{$WEAKLINE_LAST_BACKGROUND}${WEAKLINE_ICONS[LEFT_SEPARATOR]}%f$k"
	fi
	
	echo -n "%K{$2}%F{$3} $1 %f%k"
	WEAKLINE_LAST_BACKGROUND=$2
}

function weakline_write_rsegment() {
	if ! [[ -z $WEAKLINE_LAST_BACKGROUND ]]; then
		echo -n "%K{$2}%F{$WEAKLINE_LAST_BACKGROUND}${WEAKLINE_ICONS[RIGHT_SEPARATOR]}%f$k"
	else
		echo -n "%F{$2}${WEAKLINE_ICONS[RIGHT_SEPARATOR]}%f"
	fi
	
	echo -n "%K{$2}%F{$3} $1 %f%k"
	WEAKLINE_LAST_BACKGROUND=$2
}

function weakline_beginprompt() {
	WEAKLINE_LAST_BACKGROUND=""
}

function weakline_endprompt() {
	if [[ -n $WEAKLINE_LAST_BACKGROUND ]]; then
		echo -n "%F{$WEAKLINE_LAST_BACKGROUND}${WEAKLINE_ICONS[LEFT_SEPARATOR]}%f"
	fi
}

function weakline_context() {
	weakline_write_segment "$USER@$HOST" $WEAKLINE_CONTEXT_BACKGROUND $WEAKLINE_CONTEXT_FOREGROUND
}

function weakline_dir() {
	icon=$WEAKLINE_ICONS[FOLDER]
	#path="%(5~|.../%3~|%~)"
	path="%(5~|%-1~/.../%3~|%4~)"
	
	if [[ $(print -P "%~") == "~" ]]; then
		icon=$WEAKLINE_ICONS[HOME]
	elif [[ $(print -P "%~") == "~"* ]]; then
		icon=$WEAKLINE_ICONS[HOME_SUB]
	fi
	
	weakline_write_segment "$icon $path" $WEAKLINE_DIR_BACKGROUND $WEAKLINE_DIR_FOREGROUND	
}

function weakline_vcs() {
	if [[ -n "${vcs_info_msg_0_}" ]]; then
		background=$WEAKLINE_VCS_BACKGROUND
		
		if [[ -n "${vcs_info_msg_1_}" ]]; then
			background=$WEAKLINE_VCS_CHANGED_BACKGROUND
		fi
	
		weakline_write_segment "${vcs_info_msg_0_}${vcs_info_msg_1_}" $background $WEAKLINE_VCS_FOREGROUND
	fi
}

function weakline_indicator() {
	weakline_write_segment "%(!,#,$)" $WEAKLINE_INDICATOR_BACKGROUND $WEAKLINE_INDICATOR_FOREGROUND
}

function weakline_duration() {
	weakline_write_rsegment "$(pretty-time.zsh $WEAKLINE_DURATION)" white black
}

WEAKLINE_SEGMENTS=(
	"weakline_beginprompt"
	"weakline_context"
	"weakline_dir"
	"weakline_vcs"
	"weakline_endprompt"
	"echo"
	"weakline_beginprompt"
	"weakline_indicator"
	"weakline_endprompt"
)
WEAKLINE_RSEGMENTS=(
	"weakline_beginprompt"
	"weakline_duration"
)

PROMPT="\$(${(j:;:)WEAKLINE_SEGMENTS}) "
PROMPT2=`echo -n "%K{white}%F{black} %_ %f%k${WEAKLINE_ICONS[LEFT_SEPARATOR]} "`
RPROMPT=" \$(${(j:;:)WEAKLINE_RSEGMENTS})"