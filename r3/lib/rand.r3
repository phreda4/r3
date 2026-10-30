| numeros aleatorios
| PHREDA 2010

##seed8 12345 | seed of rand8 (8-bit generator)

::rand8 | -- r8 ; fast 8-bit random number 0..255 (shift register on seed8)
  seed8              	| s
  dup 3 >> over xor   | s noise
  dup 1 and 30 <<		| s n c
  rot 1 >> or
  'seed8 !
  $ff and ;

##seed $a3b195354a39b70d | seed of rand, rnd and their max/minmax words (use rerand to change it)

::rerand | s1 s2 -- ; set the seed of rand, rnd and rndmax from two values
  $a3b195354a39b70d * + 'seed ! ;

|---- muladd   
::rand | -- rand ; 64-bit random number (multiply-add generator on seed), can be negative
  seed $da942042e4dd58b5 * 1 + dup 'seed ! ;

::randmax | max -- rand ; random number 0..max-1 (max itself is never returned)
	rand 1 >>> 63 *>> ; | only positive
	
::randminmax | min max -- rand ; random number min..max-1 (max itself is never returned)
	over - randmax + ;
  
|---- xorshift
::rnd | -- rand ; 64-bit random number (xorshift on seed, which must not be 0), can be negative; not an alias of rand
    seed dup 13 << xor dup 7 >> xor dup 17 << xor dup 'seed ! ;

::rndmax | max -- rand ; like randmax but using rnd: 0..max-1
	rnd 1 >>> 63 *>> ;
	
::rndminmax | min max -- rand ; like randminmax but using rnd: min..max-1
	over - rndmax + ;	

|---- xorshit128+
#state0 1
#state1 2

::rnd128 | -- n ; 64-bit random number (xorshift128+, its own state)
	state0 state1 dup 'state0 !
	swap
	dup 23 << xor
	dup 17 >>> xor
	over xor
	swap 26 >>> xor
	dup 'state1 ! ;


|https://github.com/danielcota/LoopMix128

#fast_loop $DEADBEEF12345678
#slow_loop $ABCDEF0123456789
#mix $123456789ABCDEF

:GR $9e3779b97f4a7c15 ;

:rotLeft5 | x k -- v 
	dup 5 << swap 64 5 - >>> or ;
	
:rotLeft47 | x k -- v 
	dup 47 << swap 64 47 - >>> or ;

| LoopMix128 generator function
::loopMix128 | -- rand ; 64-bit random number (LoopMix128 generator by Daniel Cota, its own state)
	mix fast_loop + GR *
	
	fast_loop 0? ( GR 'slow_loop +! mix slow_loop xor 'mix ! ) drop

	mix rotLeft5 fast_loop + 'mix !
	fast_loop rotLeft47 GR + 'fast_loop !
	;