# r3 programming language

r3 is a concatenative language of the forth family, more precisely it takes elements of ColorForth. Word colors are encoded by a prefix: in r3 this prefix is explicit.

This is the second experiment, now all the Cells are 64 bits long, have more option for diferenct bits size in memory and only have access to Operating System with Dinamic Library, this make more easy to compile to other OS.

Now the graphic library is not mandatory, then boot in console mode.

This make posible utilice any Library, test with SDL2, SDLmixer, SDLTTF and FFMPEG. I'm interest in connect with OPENGL, VULKAN, FCGI, MariaDB or whatever need.

This version start in WIN enviroment, I try to run in LINUX and Raspberry PI 4 commming next, I not have mac but the R3d4 is working on this system, I hope this working too.

The vm used here is
https://github.com/phreda4/r3evm

## How the language works

A WORD is defined as a sequence of letters separated by spaces, there are three exceptions to improve the expressiveness of the language that are seen later.

Each word can be a number or is searched in the DICTIONARY.

If it is a valid number, in decimal, binary (%), hexa ($) or fixed point (0.1) its value is pushed to DATA STACK.

Like all FORTH, the DATA STACK is the memory structure used to perform intermediate calculations and pass parameters between words.

If the word is NOT a valid number, then it is searched in the DICTIONARY, if it is not found, it is an ERROR, the rule is "every word used must be defined before".

The language has a BASIC DICTIONARY that is already defined, from which new WORDS are defined that will be used to build the program.

## BASE word list:

We use `|` to indicate comment until the end of the line (the first exception to word separation).

Each word can take and/or leave values of the DATA STACK, this is expressed with a state diagram of the stack before -- and after the word.

for example

```
+ | a b -- c
```
the word + takes the two elements from the top of the DATA STACK, consumes them and leaves the result.
In addition to a modification in the stack, there may also be a lateral action, for example:

```
; | --
```
It does not consume or produce values in the stack but end a word 

```
;	| End of Word
(  )	| Word block to build IF and WHILE
[  ]	| Word block to build nameless definitions
EX	| Run a word through your address
```

## Conditional, together with blocks make the control structures
```
0? 1?	| Zero and non-zero conditionals
+? -?	| Conditional positive and negative
<? >?	| Comparison conditions
=? >=? 	| Comparison conditions
<=? <>?	| Comparison conditions
AND? NAND?	| Logical conditioners AND and NOT AND
BT?	| Conditional between
```

## Words to modify the DATA STACK
```
DUP	| a -- a a
DROP	| a --
OVER	| a b -- a b a
PICK2	| a b c -- a b c a
PICK3	| a b c d -- a b c d a
PICK4	| a b c d e -- a b c d e a
SWAP	| a b -- b a
NIP	| a b -- b
ROT	| a b c -- b c a
2DUP	| a b -- a b a b
2DROP	| a b --
3DROP	| a b c --
4DROP	| a b c d --
2OVER	| a b c d -- a b c d a b
2SWAP	| a b c d -- c d a b
```

## Words to modify the RETURN STACK
```
>R	| a --		; r: -- a
R>	| -- a 		; r: a --
R@	| -- a 		; r: a -- a
```

## Logical operators
```
AND	| a b -- c
OR	| a b -- c
XOR	| a b -- c
NOT	| a -- b
```

## Arithmetic Operators
```
+	| a b -- c
-	| a b -- c
*	| a b -- c
/	| a b -- c
<<	| a b -- c
>>	| a b -- c
>>>	| a b -- c
MOD	| a b -- c
/MOD	| a b -- c d
*/	| a b c -- d
*>>	| a b c -- d
<</	| a b c -- d
NEG	| a -- b
ABS	| a -- b
SQRT	| a -- b
CLZ	| a -- b
```

## Access to Memory

`@` fetch a value from memory
`!` store a value in memory

```
@	| a -- [a] ; 64 bits
C@	| a -- byte[a] ; 8 bits
W@	| a -- word[a] ; 16 bits
D@	| a -- dword[a] ; 32 bits
@+	| a -- b [a] ; 64 bits
C@+	| a -- b byte[a] ; 8 bits
W@+	| a -- b word[a] ; 16 bits
D@+	| a -- b dword[a] ; 32 bits
!	| a b -- ; 64 bits
C!	| a b -- ; 8 bits
W!	| a b -- ; 16 bits
D!	| a b -- ; 32 bits
!+	| a b -- c ; 64 bits
C!+	| a b -- c ; 8 bits
W!+	| a b -- c ; 16 bits
D!+	| a b -- c ; 32 bits
+!	| a b -- ; 64 bits
C+!	| a b -- ; 8 bits
W+!	| a b -- ; 16 bits
D+!	| a b -- ; 32 bits
```

## Help registers facility

Registers to traverse memory and read, copy or fill values

```
>A	| a --	; pop DATA STACK to A
A>	| -- a	; push A in DATA STACK
A+	| a --	; add to A

A@	| -- a	; 64 bits
A!	| a --
A@+	| -- a
A!+	| a --

CA@		| -- a	; 8 bits
CA!		| a --
CA@+	| -- a
CA!+	| a --

DA@		| -- a	; 32 bits
DA!		| a --
DA@+	| -- a
DA!+	| a --

>B	| a --	; pop DATA STACK to B
B>	| -- a	; push B in DATA STACK
B+	| a --	; add to B

B@	| -- a	; 64 bits
B!	| a --
B@+ | -- a
B!+ | a --

CB@	| -- a	; 8 bits
CB!	| a --
CB@+ | -- a
CB!+ | a --

DB@	| -- a	; 32 bits
DB!	| a --
DB@+ | -- a
DB!+ | a --

```

## Copy and Memory Filling

Block memory operation, only for data memory

```
MOVE	| dst src cnt --	; 64 bits
MOVE>	| dst src cnt --
FILL	| dst fill cnt --
CMOVE	| dst src cnt --	; 8 bits
CMOVE>	| dst src cnt --
CFILL	| dst fill cnt --
DMOVE	| dst src cnt --	; 32 bits
DMOVE>	| dst src cnt --
DFILL	| dst fill cnt --
```

## OS comunication

```
MEM		| -- a	; start free memory
LOADLIB	| "" -- a 
GETPROC | "" a -- a
SYS0	| a -- a
SYS1	| ab -- a
SYS2	| abc -- a
SYS3	| abcd -- a
SYS4	| abcde -- a
SYS5 	| abcdef -- a
SYS6	| abcdefg -- a
SYS7	| abcdefgh -- a
SYS8	| abcdefghi -- a
SYS9	| abcdefghij -- a
SYS10 	| abcdefghijk -- a
```

## Prefixes in words

* `|` ignored until the end of the line, this is a comment
* `^` the name of the file to be included is taken until the end of the line, this allows filenames with spaces.
* `"` the end of quotation marks is searched to delimit the content, if there is a double quotation mark `""` it is taken as a quotation mark included in the string.
* `:` define action
* `::` define action and this definition prevails when a file is included (* exported)
* `#` define data
* `##` define exported data
* `$` define hexadecimal number
* `%` defines binary number, allows the `.` like `0`
* `'` means the direction of a word, this address is pushed to DATA STACK, it should be clarified that the words of the BASIC DICTIONARY have NO address, but those defined by the programmer, yes.

Programming occurs when we define our own words.
We can define words as actions with the prefix:

```
:addmul + * ;
```

or data with the prefix #

```
#lives 3
```

`: ` only is the beginning of the program, a complete program in r3 can be the following

```
:sum3 dup dup + + ;

: 2 sum3 ;
```


## Conditional and Repeat

The way to build conditionals and repetitions is through the words `(` and `)`

for example:
```
5 >? ( drop 5 )
```

The meaning of these 6 words is: check the top of the stack with 5, if it is greater, remove this value and stack a 5.

The condition produces a jump at the end of the code block if it is not met. It becomes an IF block.

r3 identifies this construction when there is a conditional word before the word `(`. If this does not happen the block represents a repetition and, a conditional in that this repetition that is not an IF is used with the WHILE condition.

for example:
```
1 ( 10 <?
	1 + ) drop
```

account from 1 to 9, while the Top of stack is less 10.

You have to notice some details:

There is no IF-ELSE construction, this is one of the differences with: r4, on the other hand, ColorForth also does not allow this construction, although it seems limiting, this forces to factor the part of the code that needs this construction, or reformulate the code.

In: r4 could be constructed as follows

```
...
1? ( notzero )( zero )
follow
```

It must become:

```
:choice 1? ( nocero ; ) zero ;

...
choice
follow
```

Sometimes it happens that rethinking code logic avoids ELSE without the need to do this factoring. There are also tricks with bit operations that allow you to avoid conditionals completely but this no longer depends on the language.

Another feature to note that it is possible to perform a WHILE with multiple output conditions at different points, I do not know that this construction exists in another language, in fact it emerged when the way to detect the IF and WHILE was defined

```
'list ( c@+
	1?
	13 <>?
	emit ) 2drop
```

Does this repetition meet that the byte obtained is not 0 ` 1? ` and that is not 13 ` 13 <>? `, in any of the two conditions the WHILE ends

Another possible construction, that if it is in other FORTH, is the definition that continues in the following.
For example, define1 adds 3 to the top of the stack while define2 adds 2.

```
:define1 | n -- n+3
	1 +
:define2 | n -- n+2
	2 + ;
```

## Recursion

Recursion occurs naturally, when the word is defined with ` : ` it appears in the dictionary and it is possible to call it even when its definition is not closed.

```
:fibonacci | n -- f
	2 <? ( 1 nip ; )
	1 - dup 1 - fibonacci swap fibonacci + ;
```

## Call Optimization

When the last word before a `;` is a word defined by the programmer, both in the interpreter and in the compiler, the call is translated into JMP or jump and not with a CALL or call with return, this is commonly called TAIL CALL and saves a return in the chain of words called.

This feature can convert a recursion into a loop with no callback cost, the following definition has no impact on the return stack.

```
:loopback | n -- 0
	0? ( ; )
	1 -
	loopback ;
```

## Youtube Videos

https://www.youtube.com/playlist?list=PLTXylaG4SqxP86WQXKJBbPiNWYk5AF6Jn





