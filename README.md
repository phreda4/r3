# R3 programming language

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/phreda4/r3)

R3 is a concatenative language of the forth family, it takes elements of ColorForth. 
Word colors are encoded by a prefix: in r3 this prefix is explicit.

The size of cells is 64 bits, but you can access to memory in 8,16 or 32 bit size.

R3 can load and call procedures from any dynamic library (.DLL in windows) the distro use SDL2 library for make games.

[r3forth Manual](https://github.com/phreda4/r3/wiki/r3forth-Manual).

## WINDOWS
Download the code of this repository, uncompress and execute r3.exe

<img width="400" alt="image" src="https://github.com/user-attachments/assets/5ddc3924-0463-4a59-b8d6-fa3b48c271a6" />

The main.r3 execute by r3.exe is a browser for files in /r3 folder

with the keys you can navigate while see the code in the left side of the screen.

<img width="360" alt="image" src="https://github.com/user-attachments/assets/bd0785a6-ddd1-4afc-8d35-8af8d5a5331f" /><img width="360" alt="image" src="https://github.com/user-attachments/assets/1b8edc5b-c4ed-42b6-b263-76d491cf5375" />


Edit with F2 or execute with F1 the code in this folder. When execute a code with F1 you can see in terminal the compilation

## LINUX

Download the code of this repository, uncompress in a folder
You need sdl2 library installed in the system, 
For install sdl2 and make ./r3lin executable

```
sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev
chmod 777 ./r3lin
```

now, you can run the system

```
./r3lin
```

***

## [More code to play](https://github.com/phreda4/r3-games)

## [Youtube Videos](https://www.youtube.com/@pablohreda)

## [History](https://github.com/phreda4/r3/wiki/History)

## [WIKI](https://github.com/phreda4/r3/wiki/Welcome-to-the-r3-wiki!)

## [How the language works](https://github.com/phreda4/r3/wiki/Mini-Manual-R3)

The language use a virtual machine for work, this is the source code for this lang:
https://github.com/phreda4/r3evm

