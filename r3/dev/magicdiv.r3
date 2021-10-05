| calculo de division por multiplicacion
| http://www.flounder.com/multiplicative_inverse.htm
|------------------------
^r3/win/console.r3

#ad		| d absoluto
#t
#anc
#p
#q1
#r1
#q2
#r2

#mn		| magic mult
#sn		| shift mult

:2*	1 << ;

:calcstep
	1 'p +!
	q1 2* 'q1 !
	r1 2* 'r1 !
	r1 anc >=? ( 1 'q1 +! anc neg 'r1 +! ) drop
	q2 2* 'q2 !
	r2 2* 'r2 !
	r2 ad >=? ( 1 'q2 +! ad neg 'r2 +! ) drop
	;


:calcmagic | d --
	dup abs 'ad !
    $80000000 over 31 >>> + 't !
    t dup 1 - swap ad mod - 'anc !
    31 'p !
    $80000000 anc / abs 'q1 !
    $80000000 q1 anc * - abs 'r1 !
	$80000000 ad / abs 'q2 !
	$80000000 q2 ad * - abs 'r2 !
	( calcstep
		ad r2 -	| delta
		q1 =? ( r1 0? ( swap 1 + swap ) drop )
		q1 >? drop ) drop
	q2 1 +
	swap -? ( swap neg swap )
	drop
	'mn !
	p 'sn !
	;

:divc | nn -- res
	mn sn *>> dup 31 >> - ;

|------ metodo2
#sn2 #mn2

:calcmagic2 | div --
	$100000000 swap /. 'mn2 !
	32 'sn2 !
	;

:divc2
	mn2 sn2 *>> dup 31 >> - ;

|--------------------------
:inversemod | a -- x
	dup | a x 2
	2 pick2 pick2 * - *
	2 pick2 pick2 * - *
	2 pick2 pick2 * - *
	2 pick2 pick2 * - *
	nip
	;

|------------- test
#nro 22

:
	.cls 
	nro calcmagic
	nro calcmagic2
	nro "/%d" .print cr

	sn mn "%h %h *>> " .print cr
	sn2 mn2 "%h %h *>> " .print cr
	cr
	-80 ( 80 <? 11 +
		nro over "%d/%d=" .print
		dup nro / "%d " .print
		dup divc "%d " .print
		dup divc2 "%d " .print
		cr ) drop

	.input
	;

