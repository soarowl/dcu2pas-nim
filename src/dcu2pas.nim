import config
import glob
import parsers
import std/strformat

proc dcu2pas(files: seq[string], v = false): void =
  ##[ Decompile dcu(Delphi Compiled Unit) to pas. ]##

  if v:
    echo copyright
    return

  for pattern in files:
    for file in walkGlob(pattern):
      echo fmt"Processing: {file}"
      var dcu = newDcu(file)
      dcu.decompile()
      dcu.close()

when isMainModule:
  import cligen
  dispatch dcu2pas, help = {"files": "Files to decompile", "v": "version"}
