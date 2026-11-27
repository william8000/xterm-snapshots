# xterm for slow, high-latency connections

This is a fork of [xterm-snapshots](https://github.com/ThomasDickey/xterm-snapshots),
Thomas Dickey's snapshots of [xterm](https://invisible-island.net/xterm/).

This branch has patches that make xterm much faster when the X server is
far away, for example over `ssh -X` or a VPN, where each round trip to the
server can take tens or hundreds of milliseconds.
Stock xterm waits for many replies from the server while it starts, so a
new window can be slow to appear.
These patches remove most of those waits.
Scrolling is faster too.

The `master` branch is an unmodified copy of upstream.
This branch is rebased onto it after each new snapshot.

## What changed

Startup:

- Atoms that Xt, Xlib and xterm need are requested in one batch.
- Font metrics are cached on disk, per X server, in
  `$XDG_CACHE_HOME/xterm/fonts` (default `~/.cache/xterm/fonts`).
  Entries unused for 30 days are removed.
- Colors and cursor colors are computed locally on TrueColor visuals instead
  of asking the server.
- xterm no longer reads back window properties and hints that it just set.
- The font path, modifier map and other server data are prefetched with XCB.
- In UTF-8 mode, the UTF-8 fonts are loaded first instead of after the
  default fonts.
- Core cursors are created without Xcursor unless `cursorTheme` is set.

Running:

- Scrolling does not wait for the server after each copy.
- The Xaw scrollbar thumb is drawn in a solid color instead of a stipple.

Defaults that differ from upstream:

- `activeIcon` defaults to `false`.

The branch also has the Fedora patches, a `xterm.spec` and a
`nightly_build.sh` build script.

## Building

```sh
./nightly_build.sh
```

or the usual

```sh
./configure && make
```

See the upstream [README](README) and the
[xterm home page](https://invisible-island.net/xterm/) for everything else.
