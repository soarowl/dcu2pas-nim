import std/strformat
import src/config

# Project information
version = pkgVersion
author = pkgAuthor
description = pkgDescription
license = "MIT"
srcDir = "src"
bin = @["dcu2pas"]

# Dependencies

requires "cligen >= 1.6.18"
requires "binarylang"
requires "glob >= 0.11.3"
requires "nim >= 2.0.2"

const options = "-d:release --passL:-static"

task dev, "Build dcu2pas for Linux (x64)":
  exec fmt"nim c src/dcu2pas.nim"
  exec "mv src/dcu2pas bin/dcu2pas"

task linux, "Build dcu2pas for Linux (x64)":
  exec fmt"nim c {options} src/dcu2pas.nim"
  exec "mv src/dcu2pas bin/dcu2pas"
  withDir("bin"):
    exec "strip dcu2pas"
    exec "upx -9 --lzma dcu2pas"
    exec fmt"7z a dcu2pas-linux-v{version}.7z config dcu2pas"

task windows, "Build dcu2pas for Windows (x64)":
  exec fmt"nim c -d:mingw {options} src/dcu2pas.nim"
  exec "mv src/dcu2pas.exe bin/dcu2pas.exe"
  withDir("bin"):
    exec "strip dcu2pas.exe"
    exec "upx -9 --lzma dcu2pas.exe"
    exec fmt"7z a dcu2pas-windows-v{version}.7z config dcu2pas.exe"

task release, "Build for Linux and Windows":
  linuxTask()
  windowsTask()
