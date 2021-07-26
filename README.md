# TinyInjector

A tiny injector using LoadLibrary written in ASM.

This injector uses plain LoadLibrary without any protection or bypasses.

To avoid VAC bans, you can use [TinyBypass](https://github.com/extremeblackliu/TinyBypass).

## Default configuration

- Process name: `csgo.exe`
- DLL path: `1.dll` (relative to current working directory)

Process name and dll can be changed in lines 18 and 20.

If you are using a custom process name together with [TinyBypass](https://github.com/extremeblackliu/TinyBypass), you also need to [change the process name in TinyBypass](https://github.com/extremeblackliu/TinyBypass#default-configuration).
