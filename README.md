# R3 programming language

R3 is a concatenative language of the forth family, it takes elements of ColorForth. 
Word colors are encoded by a prefix: in r3 this prefix is explicit.

The size of cells is 64 bits, but you can access to memory in 8,16 or 32 bit size.

R3 can load and call procedures from any dynamic library (.DLL in windows) the distro use SDL2 library for make games.

Download the code of this repository, uncompress and execute r3.exe

![Screenshot for execute r3](doc/web/r3-1.png)

The main.r3 execute by r3.exe is a browser for files in /r3 foler

a more extensive description are in

[## How the language works](doc/web/HOWORK.md)

The language use a virtual machine for work, this is the source code for this lang:
https://github.com/phreda4/r3evm

## More code to play

https://github.com/phreda4/r3-games
download and decompress in the r3/r3 folder

## Youtube Videos

https://www.youtube.com/playlist?list=PLTXylaG4SqxP86WQXKJBbPiNWYk5AF6Jn

[## History](doc/web/HISTORY.md)

