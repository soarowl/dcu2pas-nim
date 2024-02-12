import binarylang
import std/[strformat, os]

type Dcu = ref object of RootObj
  filename: string
  stream: BitStream
  name: string

proc newDcu*(filename: string): Dcu =
  result = Dcu(filename: filename)
  result.stream = newFileBitStream(filename)

proc close*(d: Dcu): void =
  d.stream.close()

proc decompile*(d: var Dcu): void =
  let (dir, name, ext) = splitFile(d.filename)
  d.name = name
  let content =
    fmt"""unit {d.name};

interface
  
implementation
  
end.
"""
  if dir != "":
    writeFile(fmt"{dir}/{name}{ext}.pas", content)
  else:
    writeFile(fmt"{name}{ext}.pas", content)
