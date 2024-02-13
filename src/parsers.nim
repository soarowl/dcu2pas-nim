import binarylang
import std/[strformat, times]

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

struct(timeStamp, endian = l, bitEndian = r):
  u5:
    second
  u6:
    minute
  u5:
    hour
  u5:
    day
  u4:
    month
  u7:
    year

proc `$`*(t: TimeStamp): string =
  fmt"{t.year + 1980:04d}-{t.month:02d}-{t.day:02d} {t.hour:02d}:{t.minute:02d}:{t.second * 2:02d}"

proc toDateTime*(t: TimeStamp): DateTime =
  result = dateTime(
    (t.year + 1980).int,
    t.month.Month,
    t.day.MonthdayRange,
    t.hour.HourRange,
    t.minute.MinuteRange,
    (t.second * 2).SecondRange,
  )

proc toTimeStamp*(dt: DateTime): TimeStamp =
  let year = dt.year - 1980
  result = TimeStamp(
    year: year.uint8,
    month: dt.month.uint8,
    day: dt.monthday.uint8,
    hour: dt.hour.uint8,
    minute: dt.minute.uint8,
    second: dt.second.uint8 div 2,
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
