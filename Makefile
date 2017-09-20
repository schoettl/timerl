
.PHONY: install

install:
	mkdir -p ~/.config/timerl/
	mkdir -p ~/.cache/timerl/
	cp alarm-program.sh ~/.config/timerl/timerl_alarm
	cp alarm.wav ~/.cache/timerl/alarm.wav
