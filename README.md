# R3 programming language

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/phreda4/r3)

R3 is a concatenative language of the forth family, it takes elements of ColorForth. 
Word colors are encoded by a prefix: in r3 this prefix is explicit.

The size of cells is 64 bits, but you can access to memory in 8,16 or 32 bit size.

R3 can load and call procedures from any dynamic library (.DLL in windows) the distro use SDL2 library for make games.

[r3forth Manual](https://github.com/phreda4/r3/wiki/r4forth-Manual).

## WINDOWS
Download the code of this repository, uncompress and execute r3.exe

<img src="https://github.com/user-attachments/assets/e74f5e43-7988-4d20-a2ed-20de9cca0521" width="400">

The main.r3 execute by r3.exe is a browser for files in /r3 folder

with the keys you can navigate while see the code in the left side of the screen.

<img src="https://github.com/user-attachments/assets/10b82f55-4155-4832-bef3-9e664712c338" width="360"><img src="https://github.com/user-attachments/assets/42410ae3-31e4-4853-b352-adedbd34e295" width="360">

Edit with F2 or execute with F1 the code in this folder. When execute a code with F1 you can see in terminal the compilation

## LINUX
you need sdl2 library installed in the system, Download the code of this repository, uncompress in a folder and make executable ./r3lin file.

```
chmod 777 ./r3lin
```

now, you can run the system

```
./r3lin
```

I try in pop_os!, for install sdl2:
```
sudo apt install libsdl2-dev
```

***

## [More code to play](https://github.com/phreda4/r3-games)

## [Youtube Videos](https://www.youtube.com/@pablohreda)

## [History](https://github.com/phreda4/r3/wiki/History)

## [WIKI](https://github.com/phreda4/r3/wiki/Welcome-to-the-r3-wiki!)

## [How the language works](https://github.com/phreda4/r3/wiki/Mini-Manual-R3)

The language use a virtual machine for work, this is the source code for this lang:
https://github.com/phreda4/r3evm

