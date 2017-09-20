timerl
======

This is a command-line timer and alarm program for GNU/Linux desktops.

Examples:

```
# 3 minutes when tea is ready
timerl -m 'Tea is ready' 3m

# Shutdown in 1.5 hours
sudo timerl -c 'poweroff' 1.5h

# At 3pm
timerl 3pm
timerl 15:00
```

It is not a stopwatch. You can use `time read` or an online service instead.

You could create an alias for `timerl`, e.g. `alias tl=timerl`

Oh, and the last letter of `timerl` is an l (as Lima), not the number one.

Dependencies
------------

- A system notification service must be installed (comes with most modern desktop
  environments like Gnome, KDE, Ubuntu). An example for a light-weight notification
  service is [dunst](https://github.com/dunst-project/dunst).
- `notify-send` must be installed to interact with the notification service.
- When using `timerl` with fixed times (as in the third example), the `atd` service
  must be installed to allow scheduled tasks using `at`.
