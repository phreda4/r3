kiy 250923

## Intro

This is how to get r3 from GitHub and start using it *under Linux*.
The purpose is to leave a note for myself that others can see as well.
Pleae beware that it should include lots of errors.

## From GitHub to your computer

Things in this section can be skipped if you are not going to use GitHub services; just download the tarball, extract, and skip to the next section.

Install a GitHub Desktop app, which is easier than using commands.
Make a GitHub account as the Desktop app explains.

In your browser go to GitHub [https://github.com/phreda4/r3].
Click the Fork button at the top right of the repository page.
This creates your own copy of the r3 repo.

Copy the forked repo URL.
In your terminal, run

```
git clone r3
```

Since you'll be making changes to the repo, make a branch such as

```
git checkout -b r3k
```

Here r3k is any name you can remember that it's your own branch of r3 main repo.

## Instructions in README.md

This section is mainly from `r3/README.md`.
Download the code of this repository, uncompress in a folder.
You need sdl2 library installed in the system, 
To install sdl2 and make `./r3lin` executable, do

```
sudo apt install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-de
```

```
chmod +x ./r3lin
```

## Test run

Now you can run the system by

```
./r3lin
```

It starts up an interface to the r3 VM (virtual machine).
If it does something, probably the VM is ok.
But the interface liekly doesn't work satisfactorily.
In my case the `[F2]` button at the top of the listener didn't work.

Unlike other Forths, **r3 has no REPL** (read-eval-print loop).
So you have to try a simpler test to see that the VM itself is functional.
If

make a txt file call this 'test0.r3' with 

```
^r3/lib/console.r3

:
"r3 vm working." .println 
;
```
execute

```
./r3lin test0.r3
```
produces something like

```
r3vm - PHREDA
compile:r3/r3vm/test0.r3... ok.
inc:11 - words:524 - code:14Kb - data:8Kb - free:10231Kb

r3 vm working.
```
then the VM should be ok.

## Convenience

To make the VM easier to use, add this line

```
alias r3='cd $HOME/r3; $HOME/r3/r3lin'
```

to `~/.bash_aliases` and do

```
source ~/.bash_aliases
```

Then invoking `r3` puts you in the right directory and runs r3. 
It is important to be in `$HOME/r3` because r3 programs will load other programsin locations relative to `$HOME/r3`.
