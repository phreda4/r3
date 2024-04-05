| numeros aleatorios
| PHREDA 2010

##seed8 12345

::rand8 | -- r8
  seed8              	| s
  dup 3 >> over xor   | s noise
  dup 1 and 30 <<		| s n c
  rot 1 >> or
  'seed8 !
  $ff and ;

##seed $a3b195354a39b70d

::rerand | s1 s2 --
  $a3b195354a39b70d * + 'seed ! ;

|---- muladd   
::rand | -- rand 
  seed $da942042e4dd58b5 * 1 + dup 'seed ! ;

::randmax | max -- rand ; 0..max
	rand 1 >>> 63 *>> ; | only positive
	
::randminmax | min max -- rand ; min..max
	over - randmax + ;
  
|---- xorshift
::rnd | -- rand
    seed dup 13 << xor dup 7 >> xor dup 17 << xor dup 'seed ! ;

::rndmax | max -- rand ; 0..max
	rnd 1 >>> 63 *>> ;
	
::rndminmax | min max -- rand ; min..max
	over - rndmax + ;	

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
