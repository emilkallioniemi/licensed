#!/bin/sh
# Ticket 05 offline placeholder; ticket 23 replaces speech coverage/voice.
set -eu
rendered=$(mktemp /tmp/licensed-failure.XXXXXX.aiff)
trap 'rm -f "$rendered"' EXIT
say -v Daniel -o "$rendered" 'We will leave it there.'
afconvert -f WAVE -d LEI16 "$rendered" "$(dirname "$0")/temporary_failure.wav"
python3 -c 'import sys,wave; audio=wave.open(sys.argv[1]); assert audio.getnframes() > 0, "Speech renderer produced no audio"' "$(dirname "$0")/temporary_failure.wav"
