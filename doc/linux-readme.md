# How to start using r3 under linux
kiy 250923-250928

## Intro

What follows is why and how to get r3 from GitHub and 
start using it **under linux**. 
The note is personal.
Pleae beware that it should include lots of errors.

## Why r3

- Fun to program.
- PHREDA is *very* helpful.

### Pros

- Minimalist.
- Seems portable to cheaper devices.
- Fixed point 48.16 is supported in place of floats.

### Cons

- Poor documentation.
- No REPL.

## From GitHub repo to your computer

*This section is of no use if you don't use GitHub:
just download the tarball, extract, and skip to the next section.*

Install a GitHub Desktop app, which is easier than using commands.
Make a GitHub account as the Desktop app explains.

In your browser go to GitHub [https://github.com/phreda4/r3].
Click the Fork button at the top right of the repository page.
This creates your own copy of the r3 repo.

Copy the forked repo URL.
In your terminal, run

```
git clone https://github.com/phreda4/r3
```

Since you'll be making changes to the repo, make a branch such as

```
git checkout -b r3k
```

Here r3k is any name you can remember that 
it's your own branch of r3 repo.
For details do

```
man git checkout
```

## Prepare  r3lin

This section is mainly from `r3/README.md`.

Install sdl2 library:

```
sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev
```

Then make r3lin executable:

```
chmod +x ./r3lin
```

## Test run

Now you can run r3

```
cd r3
./r3lin
```

It starts up an interface to the r3 virtual machine (VM).
If it does something, probably the VM is ok.
But the interface that appears likely doesn't work as you expect.
In my case the `[F2]` button at the top of the screen didn't work.

Now unlike other Forths, **r3 has no REPL** (read-eval-print loop).
It doesn't have interactive words you expect, such as 
WORDS , FIND , FORGET , or DEPTH .
Even `3 .` doesn't work.

So to run a further test, you have to prepare a program file such as 
$HOME/r3/test-r3lin.r3  containing

```
^r3/editor/code-print.r3
: "r3lin works!" .println ;
```

The first line includes a library that defines `.println` 
that appears in the second line.
The hat (^) tells r3 to include the following file.
The second line prints "r3lin works!" .
If you do

```
cd $HOME/r3
./r3lin test-r3lin.r3
```

and see on the screen something like

```
r3vm - PHREDA
compile:test-r3lin.r3... ok.
inc:11 - words:524 - code:14Kb - data:8Kb - free:10231Kb

r3lin works!
```

then r3lin should be working.


## Convenience

To make the VM easier to use, add this line

```
alias r3='cd $HOME/r3; $HOME/r3/r3lin'
```

to `~/.bash_aliases` and do

```
source ~/.bash_aliases
```

Then invoking `r3` puts you in `$HOME/r3/` and runs `$HOME/r3/r3lin' . 
It is important to be in the right directory `$HOME/r3`
when you run  r3ling  because it will load other programs 
found in locations *relative to* `$HOME/r3`.

## REPL compensation

Use `tee` to compensate the absence of REPL in r3.

```
r3 test-r3lin.r3 | tee out.txt
```

This should produce $HOME/r3/out.txt 
besides showing the output on the terminal.
To prevent overwriting, use

```
r3 test-r3lin.r3 | tee -a out.txt
```

or

```
r3 test-r3lin.r3 | tee --append out.txt
```

## To compile r3lin

The r3 virtual machine (VM) is under development in a separade repo, `r3evm` .

```
git clone r3evm
```

```
git checkout -b r3evmk
```

In $HOME/r3evm/r3.cpp uncomment 

```
//#define LINUX
```

to

```
#define LINUX
```

and do

```
make
```

which should produce r3lin , with lots of warnings.
In case  $HOME/r3/r3lin  is lost, copy or move this r3lin to  $HOME/r3  .
