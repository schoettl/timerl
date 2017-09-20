#!/bin/bash
# Set alarm or timer

# Warning: When at is used, the commands are executed with /bin/sh

printUsage() {
    cat <<EOF
usage:
  $PROGNAME [options] TIMESPEC
  $PROGNAME -k
  $PROGNAME -h

options:
  -c SHELLCMD
      additionally execute this shell command
  -m MESSAGE
      show this message in the system notification
  -a
      force use of at (instead of sleep)
  -s
      silent, do not execute the alarm program
  -k
      kill alarm program if running
  -h
      print this help message

The alarm program is $CONFIG_ALARM_PROGRAM (which can also be a symlink).

TIMESPEC must be in a format accepted by sleep or at.
TIMESPEC     ::= SLEEP_SYNTAX | AT_SYNTAX
SLEEP_SYNTAX ::= NUMBER[s|m|h|d] ...
AT_SYNTAX    ::= complex
EOF
}

set -o errexit -o pipefail

readonly PROGNAME=$(basename "$0")

readonly CONFIG_ALARM_PROGRAM=~/.config/timerl/timerl_alarm

# $*: command line arguments = "$@"
parseCommandLine() {
    while getopts "hc:m:ask" OPTION; do
        case $OPTION in
            h) printUsage
               exit 0
               ;;
            c) declare -gr SHELL_COMMAND=$OPTARG ;;
            m) declare -gr ALARM_MESSAGE=$OPTARG ;;
            a) declare -gr FORCE_AT=1 ;;
            s) declare -gr SILENT=1 ;;
            k) declare -gr KILL_ALARM=1 ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -n $KILL_ALARM ]]; then
        if (( $# > 0 || OPTIND > 2 )); then
            exitWithError "error: you can use -k alone only"
        fi
    elif (( $# < 1 )); then
        printUsage
        exit 1
    fi

    declare -rg TIMESPEC=$*

    return 0
}

# $1: error message
exitWithError() {
    echo "$1" >&2
    exit 1
}

killAlarmProgram() {
    declare pids
    pids=$(pidof -x timerl_alarm)
    if (( ${#pids[@]} > 0 )); then
        for pid in "${pids[@]}"; do
            pkill -9 -P "$pid"
            kill -9 "$pid"
        done
    fi
}

main() {

    # Check if notify-send is installed
    if ! hash notify-send; then
        declare errorMessage="error: notification tool notify-send is not installed"
        xmessage "$PROGNAME: $errorMessage"
        exitWithError "$errorMessage"
    fi

    parseCommandLine "$@"

    if [[ -n $KILL_ALARM ]]; then
        killAlarmProgram
        exit
    fi

    declare alarmMessage=${ALARM_MESSAGE:-alarm}
    alarmMessage=${alarmMessage/\"/}

    declare scriptFile
    scriptFile=$(mktemp)
    cat <<-EOT > "$scriptFile"
	notify-send -t 0 -i info -u critical "$PROGNAME" "$alarmMessage (set at $(date +'%F %T'))"
	EOT

    if [[ -z $SILENT && -x $CONFIG_ALARM_PROGRAM ]]; then
        echo "$CONFIG_ALARM_PROGRAM &" >> "$scriptFile"
    fi

    echo "$SHELL_COMMAND" >> "$scriptFile"

    # echo "debug: script file:"
    # cat "$scriptFile"

    if [[ $TIMESPEC =~ ^[0-9.smhd]+$ && -z $FORCE_AT ]]; then
        echo "debug: using sleep"
        sleep "$TIMESPEC" \
            && /bin/sh < "$scriptFile"
    else
        echo "debug: using at"
        if ! systemctl -q is-active atd; then
            declare errorMessage="scheduling service at/atd is not running"
            notify-send -i error "$PROGNAME" "$errorMessage"
            exitWithError "error: $errorMessage"
        fi

        at "$TIMESPEC" <<< "$scriptFile"
    fi

}

main "$@"
