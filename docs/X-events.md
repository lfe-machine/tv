# X Events

Some tools for observing events.

## `xev`

Running `xev` will start up an X application that will show events when it has the focus.

## `xinput`

Run `xinput list` and then look for the ID for first keyboard under "Virtual core keyboard". If that ID is, for example, `5`, then run the following to see the events:

```
xinput test 5
```

## `showkey`

For key presses:

```
showkey -a
```
