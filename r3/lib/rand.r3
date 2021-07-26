| funciones aleatorias
| PHREDA 2010

^r3/lib/sys.r3

##seed8 12345

::rand8 | -- r8
  seed8              	| s
  dup 3 >> over xor   | s noise
  dup 1 and 30 <<		| s n c
  rot 1 >> or
  'seed8 !
  $ff and ;


##seed 495090497

::rand | -- r32
  seed 3141592621 * 1 + dup 'seed ! ;

::rerand | --
  time msec + 'seed ! ;

  
|--- Multiply-with-carry random

#listr 1 2 3 4 5

::mrand | -- xx
	'listr
	@+ 5115 * swap
	@+ 1776 * rot + swap
	@+ 1492 * rot + swap
	@+ 11111111 * rot + swap
	@ +
	'listr dup 4 - 4 move
	dup 'listr !
	dup 31 >> 'listr 16 + !
	;

::mseed | seed --
  'listr swap
  0 ( 5 <? >r
    29943829 * 1 -
    dup rot !+ swap
    r> 1 + ) 3drop ;

|------
#nseed
#rgecx

::random | -- r
	rgecx $a2348705 xor nseed xor
	dup 'nseed +! dup 'rgecx !
	;


|---- xorshift
#(rnd) 2463534242

::rndseed
	'(rnd) ! ;
::rnd | -- n
    (rnd) dup 13 << xor dup 17 >> xor dup 5 << xor dup '(rnd) ! ;

|---- xorshit128+
#state0 1
#state1 2

::rnd128 | -- n
	state0 state1 dup 'state0 !
	swap
	dup 23 << xor
	dup 17 >> xor
	over xor
	swap 26 >> xor
	dup 'state1 ! ;
