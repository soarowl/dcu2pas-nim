import ../src/parsers
import binarylang
import std/unittest

test "packed u7":
  var sbs = newStringBitStream()
  for i in [
    0, 127, 128, 255, 256, 511, 512, 1023, 1024, 2047, 2048, 4095, 4096, 8191, 8192,
    16383, 16384, 32767, 32768, 65535, 65536, 131071, 131072, 262143, 262144, 524287,
    524288, 1048575, 1048576, 2097151, 2097152, 4194303, 4194304, 8388607, 16777215,
    16777216, 33554431, 67108863, 67108864, 134217727, 134217728, 268435455, 268435456
  ]:
    sbs.seek(0)
    packedUIntParser.put(sbs, i.PackedUInt)
    sbs.seek(0)
    check packedUIntParser.get(sbs) == i.PackedUInt
