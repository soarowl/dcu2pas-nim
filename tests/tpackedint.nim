import ../src/parsers
import binarylang
import std/unittest

test "packed int":
  var sbs = newStringBitStream()
  for i in -300 .. 300:
    sbs.seek(0)
    packedIntParser.put(sbs, i)
    sbs.seek(0)
    check packedIntParser.get(sbs) == i
