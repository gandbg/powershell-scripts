# Introduction
This repository stores various scripts that I wrote and use from time to time. I wanted a Git repo to track changes and figured that someone might find this code useful.

The scripts are licensed under the [GNU LGPLv3](https://choosealicense.com/licenses/lgpl-3.0/) and have been written with Powershell 5.1 in mind ("Windows Powershell" in Windows 10/11)

# Contents
+ [`merge-flac-lrc.ps1`](./scripts/merge-flac-lrc.ps1) - Takes an absolute path (`WorkingPath` string parameter) and merges any FLAC file that has a correspondent LRC file in that folder together (copies the contents of the LRC inside the LYRICS tag of the FLAC, deleting any LYRICS tag value first)
  + Requires `metaflac` in `$PATH`, downloadable from the [Xiph.Org website](https://xiph.org/flac/download.html)
+ [`flacode.ps1`](./scripts/flacode.ps1) - Takes an absolute path (`WorkingPath` string parameter) and recompresses any FLAC file with level 8 compression (libFLAC's maximum) while preserving the `CreationTime`, `LastWriteTime` and `LastAccessTime` attributes
  + Requires `flac` (most recent version preferable) in `$PATH`, downloadable from the [Xiph.Org website](https://xiph.org/flac/download.html)
