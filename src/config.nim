import std/[strformat, strutils]

const
  pkgVersion* = "0.1.0"
  pkgAuthor* = "Zhuo Nengwen"
  pkgDescription* = "Decompile dcu(Delphi Compiled Unit) to pas."

  revision* = staticExec("git rev-parse --short HEAD")
  compiledAt* = CompileDate & " " & CompileTime
  copyright* =
    fmt"""{pkgDescription}
Author:      {pkgAuthor}
Version:     {pkgVersion}-{revision}
Compiled at: {compiledAt}"""
  fence* = "/".repeat(80)
  decompiledHeader* =
    fmt"""
{fence}
// {pkgDescription}
// Author:      {pkgAuthor}
// Version:     {pkgVersion}-{revision}
// Compiled at: {compiledAt}
{fence}"""
