# Using r3 on Linux

Notes by kiy (2025), updated.

## Install

Install the SDL2 libraries:

```
sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev
```

Get the repository (or download the zip) and make `r3lin` executable:

```
git clone https://github.com/phreda4/r3
cd r3
chmod +x ./r3lin
```

To make your own changes, work in a branch: `git checkout -b mybranch`.

## Run

Always run `r3lin` from the `r3` folder: programs load other files with paths relative to it.

```
./r3lin              # integrated environment (editor, tools)
./r3lin test0.r3     # run a program
```

First test: save this as `test0.r3`

```
^r3/lib/console.r3

: "r3lin works!" .println ;
```

`./r3lin test0.r3` should print:

```
r3vm - PHREDA
compile:test0.r3... ok.
...
r3lin works!
```

The `^` line includes a library; the `:` line without a name is the program entry point.

## REPL

r3 has no line-by-line interpreter: a program is compiled and then run. The `repl/` folder
has a text REPL environment that runs what you type:

```
./r3lin repl/repl.r3
```

To keep the output of a program in a file:

```
./r3lin test0.r3 | tee out.txt        # tee -a appends instead of overwriting
```

## Shortcut

Add to `~/.bash_aliases` (then `source ~/.bash_aliases`):

```
alias r3='cd $HOME/r3; $HOME/r3/r3lin'
```

## Build the VM

The VM source is in https://github.com/phreda4/r3evm.

```
git clone https://github.com/phreda4/r3evm
cd r3evm && make
mv r3lin ../r3/
```
