#!/bin/bash

# This is an example alarm program for timerl.
# It can be copied or linked to ~/.config/timerl/alarm
# to add a custom alarm.

# More ideas for visual alarms:
# https://serverfault.com/questions/19743/is-there-a-visual-bell-in-linux-that-works-in-x

for _ in {1..10}; do
    xrefresh -solid green

    # requires xcalib
    # problematic when killed in the wrong moment
    # reset with xcalib -c
    xcalib -alter -invert

    # https://serverfault.com/a/668143/161514
    # running instance of xvisbell required
    xkbbell

    sleep 0.2
done

paplay ~/.cache/timerl/alarm.wav

# youtube-dl -o - 'https://youtu.be/xvUuFuJHi1I' > ~/.cache/timerl/alarm.webm
# youtube-dl -g 'https://youtu.be/xvUuFuJHi1I' | grep 'mime=audio' | xargs curl > ~/.cache/timerl/alarm.webm
#mplayer -novideo ~/.cache/timerl/alarm.webm
