# Introduction
This repository stores various scripts that I wrote and use from time to time. I wanted a Git repo to track changes and figured that someone might find this code useful.

The scripts are licensed under the [GNU LGPLv3](https://choosealicense.com/licenses/lgpl-3.0/) and have been written with PowerShell 5.1 in mind ("Windows PowerShell" in Windows 10/11)

# Contents
+ [`merge-flac-lrc.ps1`](./scripts/merge-flac-lrc.ps1) - Takes an absolute path (`WorkingPath` string parameter) and merges any FLAC file that has a correspondent LRC file in that folder together (copies the contents of the LRC inside the LYRICS tag of the FLAC, deleting any LYRICS tag value first)
  + Requires `metaflac` in the `$env:PATH`, downloadable from the [Xiph.Org website](https://xiph.org/flac/download.html)
+ [`flacode.ps1`](./scripts/flacode.ps1) - Takes an absolute path (`WorkingPath` string parameter) and recompresses any FLAC file with level 8 compression (libFLAC's maximum) while preserving the `CreationTime`, `LastWriteTime` and `LastAccessTime` attributes
  + Requires `flac` (most recent version preferable) in the `$env:PATH`, downloadable from the [Xiph.Org website](https://xiph.org/flac/download.html)
+ [`mkv-audio-track-lang-rename.ps1`](./scripts/mkv-audio-track-lang-rename.ps1) - Takes an absolute path (`WorkingPath` string parameter; either a file or a folder) and renames the audio tracks of any .mkv files present based on the language tag of the track, throwing an error and exiting if the language is not recognized and using a default format if it is set to `und` ("Undefined")
  + Requires MKVToolNix in the the `$env:PATH` (specifically `mkvmerge` and `mkvpropedit`), downloadable from the [official website](https://mkvtoolnix.download/)
