WEAKLINE_INDICATOR_BACKGROUND=white
WEAKLINE_INDICATOR_FOREGROUND=black

function weakline_indicator() {
	weakline_write_segment "%(!,#,$)" $WEAKLINE_INDICATOR_BACKGROUND $WEAKLINE_INDICATOR_FOREGROUND
}