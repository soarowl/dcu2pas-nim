import config
import dcu
import glob
import std/strformat

const revision = staticExec("git rev-parse --short HEAD")

proc dcu2pas(files: seq[string], v = false): void =
  ##[ Decompile dcu(Delphi Compiled Unit) to pas. ]##

  if v:
    echo pkgDescription
    echo fmt"Author:      {pkgAuthor}"
    echo fmt"Version:     {pkgVersion}-{revision}"
    echo fmt"Compiled at: {CompileDate}  {CompileTime}"
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
