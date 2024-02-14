import binarylang
import config
import std/[strformat, os, times]

type
  Compiler* = enum
    Delphi6 = (14, "Borland Delphi 6")
    Delphi7 = (15, "Borland Delphi 7")
    Delphi8 = (16, "Borland Delphi 8 for .NET")
    Delphi2005 = (17, "Borland Delphi 2005")
    Delphi2006 = (18, "Borland Developer Studio 2006")
    Delphi2007 = (19, "CodeGear Delphi 2007 for .NET")
    Delphi2009 = (20, "CodeGear C++ Builder 2009")
    Delphi2010 = (21, "Embarcadero RAD Studio 2010")
    DelphiXE = (22, "Embarcadero RAD Studio XE")
    DelphiXE2 = (23, "Embarcadero RAD Studio XE2")
    DelphiXE3 = (24, "Embarcadero RAD Studio XE3")
    DelphiXE4 = (25, "Embarcadero RAD Studio XE4")
    DelphiXE5 = (26, "Embarcadero RAD Studio XE5")
    DelphiXE6 = (27, "Embarcadero RAD Studio XE6")
    DelphiXE7 = (28, "Embarcadero RAD Studio XE7")
    DelphiXE8 = (29, "Embarcadero RAD Studio XE8")
    Delphi10 = (30, "Embarcadero RAD Studio 10 Seattle")
    Delphi10Berlin = (31, "Embarcadero RAD Studio 10.1 Berlin")
    Delphi10Tokyo = (32, "Embarcadero RAD Studio 10.2 Tokyo")
    Delphi10Rio = (33, "Embarcadero RAD Studio 10.3 Rio")
    Delphi10Sydney = (34, "Embarcadero RAD Studio 10.4 Sydney")
    Delphi11 = (35, "Embarcadero RAD Studio 11.0 Alexandria")
    Delphi12 = (36, "Embarcadero RAD Studio 12.0 Athens")

  Platform* = enum
    Win32_00 = (0x00, "Win32")
    Win32_03 = (0x03, "Win32")
    OSX32_04 = (0x04, "OSX32")
    iOSSimulator32_14 = (0x14, "iOSSimulator32")
    Win64_23 = (0x23, "Win64")
    Android32_67 = (0x67, "Android32")
    iOSDevice32_76 = (0x76, "iOSDevice32")
    Android32_77 = (0x77, "Android32")
    Android64_87 = (0x87, "Android64")
    iOSDevice32_94 = (0x94, "iOSDevice64")

proc compilerToStr*(c: uint8): string =
  try:
    let compiler = c.Compiler
    return $compiler
  except Exception:
    return "Unknown Compiler"

proc plateformToStr*(p: uint8): string =
  try:
    let plateform = p.Platform
    return $plateform
  except Exception:
    return "Unknown Platform"

template addGet(parse, parsed, output, n: untyped) =
  parse
  output = parsed + n

template addPut(encode, encoded, output, n: untyped) =
  output = encoded - n
  encode

template mulGet(parse, parsed, output, n: untyped) =
  parse
  output = parsed * n

template mulPut(encode, encoded, output, n: untyped) =
  output = encoded div n
  encode

template uint8ToIntGet(parse, parsed, output) =
  parse
  output = parsed.int

template uint8ToIntPut(encode, encoded, output) =
  output = encoded.uint8
  encode

struct(u7, endian = l, bitEndian = r):
  u1:
    flag = 0
  u7:
    value

struct(u14, endian = l, bitEndian = r):
  u2:
    flag = 0b01
  u14:
    value

struct(u21, endian = l, bitEndian = r):
  u3:
    flag = 0b011
  u21:
    value

struct(u28, endian = l, bitEndian = r):
  u4:
    flag = 0b0111
  u28:
    value

struct(u32, endian = l, bitEndian = r):
  u8:
    flag = 0x5F
  lu32:
    value

struct(u64, endian = l, bitEndian = r):
  u8:
    flag = 0xFF
  lu64:
    value

struct(i7, endian = l, bitEndian = r):
  u1:
    flag = 0
  7:
    value

struct(i14, endian = l, bitEndian = r):
  u2:
    flag = 0b01
  14:
    value

struct(i21, endian = l, bitEndian = r):
  u3:
    flag = 0b011
  21:
    value

struct(i28, endian = l, bitEndian = r):
  u4:
    flag = 0b0111
  28:
    value

struct(i32, endian = l, bitEndian = r):
  u8:
    flag = 0x5F
  l32:
    value

struct(i64, endian = l, bitEndian = r):
  u8:
    flag = 0xFF
  l64:
    value

type
  PackedUInt* = uint64
  PackedInt* = int64

proc getPackedUInt(s: BitStream): PackedUInt =
  let u8 = s.readU8()
  s.setPosition(s.getPosition() - 1)

  if (u8 and 0b1) == 0:
    let u = u7.get(s)
    echo u
    return u.value
  if (u8 and 0b11) == 0b01:
    let u = u14.get(s)
    echo u
    return u.value
  if (u8 and 0b111) == 0b011:
    let u = u21.get(s)
    echo u
    return u.value
  if (u8 and 0b1111) == 0b0111:
    let u = u28.get(s)
    echo u
    return u.value
  if u8 == 0x5F:
    let u = u32.get(s)
    echo u
    return u.value
  if u8 == 0xFF:
    let u = u64.get(s)
    echo u
    return u.value

proc putPackedUInt(s: BitStream, input: PackedUInt) =
  if input <= 127:
    let u = U7(flag: 0b0, value: input.uint8)
    u7.put(s, u)
  elif input <= 16383:
    let u = U14(flag: 0b01, value: input.uint16)
    u14.put(s, u)
  elif input <= 2097151:
    let u = U21(flag: 0b011, value: input.uint32)
    u21.put(s, u)
  elif input <= 268435455:
    let u = U28(flag: 0b0111, value: input.uint32)
    u28.put(s, u)
  elif input <= 4294967295.uint64:
    let u = U32(flag: 0x5F, value: input.uint32)
    u32.put(s, u)
  else:
    let u = U64(flag: 0xFF, value: input.uint64)
    u64.put(s, u)

let packedUIntParser* = (get: getPackedUInt, put: putPackedUInt)

proc getPackedInt(s: BitStream): PackedInt =
  let u8 = s.readU8()
  s.setPosition(s.getPosition() - 1)

  if (u8 and 0b1) == 0:
    let ii = i7.get(s)
    echo ii
    return ii.value
  if (u8 and 0b11) == 0b01:
    let ii = i14.get(s)
    echo ii
    return ii.value
  if (u8 and 0b111) == 0b011:
    let ii = i21.get(s)
    echo ii
    return ii.value
  if (u8 and 0b1111) == 0b0111:
    let ii = i28.get(s)
    echo ii
    return ii.value
  if u8 == 0x5F:
    let ii = i32.get(s)
    echo ii
    return ii.value
  if u8 == 0xFF:
    let ii = i64.get(s)
    echo ii
    return ii.value

proc putPackedInt(s: BitStream, input: PackedInt) =
  if input >= -64 and input <= 63:
    let ii = I7(flag: 0b0, value: input.int8)
    echo ii
    i7.put(s, ii)
  elif input >= -8192 and input <= 8191:
    let ii = I14(flag: 0b01, value: input.int16)
    echo ii
    i14.put(s, ii)
  elif input >= -2097152 and input <= 2097151:
    let ii = I21(flag: 0b011, value: input.int32)
    i21.put(s, ii)
  elif input >= -268435456 and input <= 268435455:
    let ii = I28(flag: 0b0111, value: input.int32)
    i28.put(s, ii)
  elif input >= -4294967296 and input <= 4294967295:
    let ii = I32(flag: 0x5F, value: input.int32)
    i32.put(s, ii)
  else:
    let ii = I64(flag: 0xFF, value: input.int64)
    i64.put(s, ii)

let packedIntParser* = (get: getPackedInt, put: putPackedInt)

struct(timeStamp, endian = l, bitEndian = r):
  u5 {mul(2)}:
    second
  u6:
    minute
  u5:
    hour
  u5:
    day
  u4:
    month
  u7 {uint8ToInt[int], add(1980)}:
    year

proc `$`*(t: TimeStamp): string =
  fmt"{t.year:04d}-{t.month:02d}-{t.day:02d} {t.hour:02d}:{t.minute:02d}:{t.second:02d}"

proc toDateTime*(t: TimeStamp): DateTime =
  result = dateTime(
    t.year, t.month.Month, t.day.MonthdayRange, t.hour.HourRange, t.minute.MinuteRange,
    t.second.SecondRange
  )

proc toTimeStamp*(dt: DateTime): TimeStamp =
  result = TimeStamp(
    year: dt.year,
    month: dt.month.uint8,
    day: dt.monthday.uint8,
    hour: dt.hour.uint8,
    minute: dt.minute.uint8,
    second: dt.second.uint8,
  )

struct(dcuHeader, endian = l, bitEndian = r):
  u8:
    major
  u8:
    platform
  u8:
    minor
  u8:
    compiler
  lu32:
    size
  *timeStamp:
    timestamp
  lu32:
    crc

proc `$`*(h: DcuHeader): string =
  fmt"""// Compiler: {h.compiler.compilerToStr}
// Platform: {h.platform.plateformToStr}
// size: {h.size} bytes
// timestamp: {h.timestamp}
// crc: ${h.crc:08X}"""

struct(dcuBody, endian = l, bitEndian = r):
  u8:
    _ = 0

type Dcu = ref object of RootObj
  filename: string
  stream: BitStream
  name: string
  header: DcuHeader
  body: DcuBody

proc newDcu*(filename: string): Dcu =
  result = Dcu(filename: filename)
  result.stream = newFileBitStream(filename)

proc close*(d: Dcu): void =
  d.stream.close()

proc decompile*(d: var Dcu): void =
  let (_, name, _) = splitFile(d.filename)
  d.name = name

  d.header = dcuHeader.get(d.stream)
  d.body = dcuBody.get(d.stream)

  let content =
    fmt"""{decompiledHeader}

{d.header}

unit {d.name};

interface

implementation

end.
"""
  writeFile(fmt"{d.filename}.pas", content)
