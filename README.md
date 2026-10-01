# LGPT.pak — Little Piggy Tracker for TrimUI Brick (NextUI)

A NextUI pak of [Little Piggy Tracker](https://github.com/djdiskmachine/LittleGPTracker)
(formerly LittleGPTracker, a.k.a. "piggy"), the sample-based music tracker designed
for handheld game consoles rather than keyboards.

Its interface is the LSDj song/chain/phrase/table workflow that the Dirtywave M8
later popularised — which makes it the closest thing to an M8 you can run on the
Brick itself, with no extra hardware.

## Install

Copy `LGPT.pak/` to `SD_ROOT/Tools/tg5040/`, then launch **LGPT** from the Tools menu.

## Your data lives outside the pak

```
/mnt/SDCARD/LGPT/
├── lgpt_<ProjectName>/   one directory per song (lgptsav.dat + samples/)
├── samplelib/            your sample library
└── logs/                 one truncated log per launch
```

Pak updates wipe and re-unzip the pak folder, so nothing of yours is kept in there.
`config.xml` points the tracker's `root:` at this directory via `ROOTFOLDER`.

The upstream release ships a 51 MB `samplelib/` and several demo projects. They are
deliberately **not** bundled here to keep the pak small — download any
[upstream release](https://github.com/djdiskmachine/LittleGPTracker/releases) and copy
`samplelib/` and any `lgpt_*/` directories into `/mnt/SDCARD/LGPT/`.

## Controls

| Brick | Tracker |
|---|---|
| D-pad | navigate |
| A | edit / enter |
| B | cancel / back |
| L / R | modifiers (selection, copy/paste, navigation) |
| START | play / stop |

SELECT and the menu button are left unmapped — the tracker has no action bound to
them, and NextUI wants the menu button.

## Building

The binary is cross-compiled from a fork of the upstream tracker that adds a
`TG5040` platform target. See that repository for `shell.nix`,
`tools/setup-toolchain.sh` and `projects/Makefile.TG5040`.

## Licence

Little Piggy Tracker is **GPLv3**; see `LICENSE`. Source for the exact binary shipped
here is the `tg5040` branch of the fork linked above.

Credit chain: Marc Nostromo (`Mdashdotdashn`) wrote LittleGPTracker and released the
source; djdiskmachine maintains the fork this builds from.
