^r3/lib/console.r3
^r3/lib/dmath.r3

:mc	| y bitpos -- y mant
	+? ( >> ; ) neg << ;
	
::log2.d1 | x -- r
    0 <=? ( 0 nip ; )
    63 over clz -           | x bitpos
    32 - dup 32 << -rot     | bp x bp
    | Normalizar a [-0.5, 0.5) restando 1.5 en lugar de 1.0
    | para centrar mejor el rango
    mc $C0000000 -          | bp m (centrado en -0.25..0.75 → shift)
    $80000000 +             | ajuste para centrar en 0
    | Polinomio Horner grado 6 para rango simétrico
    206837197               | c6:  0.0481535
    over *.d -669292851 +   | c5: -0.1558153
    over *.d 1082034586 +   | c4:  0.2519231
    over *.d -1545812723 +  | c3: -0.3598978
    over *.d 2060485038 +   | c2:  0.4797735
    over *.d -3096031560 +  | c1: -0.7207875
    over *.d 6196324199 +   | c0:  1.4426950
    *.d + ;

::log2.d2 | x -- r
    0 <=? ( 0 nip ; )
    | CLZ y posición de bit
    dup clz                 | x clz
    dup 32 << rot swap >>   | clz mantisa_normalizada
    | Comparar con sqrt(2) ≈ 1.4142... = $16A09E668 en 1.63
    $5A827999 >? (          | sqrt(2)/2 en formato normalizado
        swap $100000000 - swap        | decrementar exponente si >= sqrt(2)
        2/                | dividir mantisa por 2
    )
    | Ahora mantisa está en [sqrt(2)/2, sqrt(2)) ≈ [0.707, 1.414)
    | Centrar en 1.0: restar $40000000 (=1.0 en 2.62)
    $40000000 -             | m en [-0.293, 0.414) ≈ [-0.5, 0.5)/√2
    2 <<                    | escalar a 32.32
    swap 31 - 32 << swap    | bp m
    | Coeficientes minimax optimizados
    -385973472              | c6
    over *.d 789498214 +    | c5  
    over *.d -1236297856 +  | c4
    over *.d 1695816294 +   | c3
    over *.d -2145874124 +  | c2
    over *.d 3082059488 +   | c1
    over *.d 6196324199 +   | c0
    *.d + ;

::log2.d3 | x -- r
	0 <=? ( 0 nip ; ) 
	63 over clz - | x bitpos
	32 - dup 32 << -rot 		| bp x bp
	mc $100000000 -	| bp x
    | Coeficientes minimax optimizados para log2(1+x)
    -1031528098      | c5: -0.2401245832
    over *.d 1233693442 +   | c4:  0.2872054815
    over *.d -1541790390 +  | c3: -0.3589659808
    over *.d 2059218540 +   | c2:  0.4794785231
    over *.d -3095779558 +  | c1: -0.7206820389
    over *.d 6196315029 +   | c0:  1.4426950216 ˜ 1/ln(2)
    *.d + ;

:test | nro --
	dup .print "=" .print
	dup str>fnro nip log2. "%f " .print
	str>f.d nip 
	dup log2.d .fd .print .sp
	dup log2.d1 .fd .print .sp
	dup log2.d2 .fd .print .sp
	log2.d3 .fd .print .sp
	.cr
	;

:aux
$200000000 sqrt.d .fd "sqrt(2)=%s" .println
$200000000 ln.d .fd "ln(2)=%s" .println
"0.0000001" str>f.d nip 
"0.0000001" str>f.d nip +
.fd "%s" .println
2.0 ln. "%f" .println

0 ( 2.0 <?
	dup "ln2(%f)=" .print
	dup log2. "%f " .print
	dup f>.d log2.d .fd .print
	0.2 + .cr ) drop
	;
:
.cls

"test ln2" .println
"0.2" test
"0.4" test
"0.6" test
"0.8" test
"1.0" test
"1.2" test
"1.4" test
"1.6" test
"1.8" test
"2.0" test


waitkey
;

