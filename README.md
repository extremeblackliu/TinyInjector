# TinyInjector

A tiny injector using LoadLibrary written in ASM.

This injector uses plain LoadLibrary without any protection or bypasses.

To inject with trusted launch, you can use [TinyBypass](https://github.com/extremeblackliu/TinyBypass) (csgo only).

## Default configuration

- Process name: `csgo.exe`
- DLL path: `1.dll` (relative to current working directory)

Process name and dll can be changed in lines 18 and 20.
