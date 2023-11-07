|---- Penner animation moves

^r3/lib/math.r3

::Lineal ;

::Quad_In	dup *. ;
::Quad_Out	2.0 over - *. ;
::Quad_InOut	1 << 1.0 <? ( Quad_In 1 >> ; ) 1.0 - Quad_Out 1 >> 0.5 + ;

::Cub_In	dup dup *. *. ;
::Cub_Out	1.0 - Cub_In 1.0 + ;
::Cub_InOut	1 << 1.0 <? ( Cub_In 1 >> ; ) 2.0 - Cub_In 2.0 + 1 >> ;

::Quar_In	dup *. dup *. ;
::Quar_Out	1.0 - Quar_In -1.0 + neg ;
::Quar_InOut	1 << 1.0 <? ( Quar_In 1 >> ; ) 1.0 - Quar_Out 1.0 + 1 >> ;

::Quin_In	dup dup *. dup *. *. ;
::Quin_Out	1.0 - Quin_In 1.0 + ;
::Quin_InOut	1 << 1.0 <? ( Quin_In 1 >> ; ) 1.0 - Quin_Out 1 >> 0.5 + ;

::Sin_In	1.0 swap 2 >> cos - ;
::Sin_Out	2 >> sin ;
::Sin_InOut	1.0 swap 1 >> cos - 1 >> ;

::Exp_In	0? ( ; ) 1.0 - 1024.0 swap pow. ;
::Exp_Out   1.0 =? ( ; ) -10 * 2.0 swap pow. 1.0 swap - ;
::Exp_InOut 1 << 1.0 <? ( Exp_In 1 >> ; ) 1.0 - Exp_Out 1 >> 0.5 + ;

::Cir_In	dup *. 1.0 swap - sqrt. 1.0 swap - ;	|18
::Cir_Out	1.0 - dup *. 1.0 swap - sqrt. ;
::Cir_InOut	1 << 1.0 <? ( Cir_In 1 >> ; ) 1.0 - Cir_Out 1 >> 0.5 + ;

::Ela_In
	0? ( ; ) 1.0 =? ( ; )
    dup 1.0 - 10 * 2.0 swap pow. neg
	swap 1.1 - 2.5 *. sin *. ;
::Ela_Out
	0? ( ; ) 1.0 =? ( ; )
	dup -10 * 2.0 swap pow.
	swap 0.1 - 2.5 *. sin *. 1.0 + ;
::Ela_InOut	1 << 1.0 <? ( Ela_In 1 >> ; ) 1.0 - Ela_Out 1 >> 0.5 + ;

::Bac_In		dup 2.7016 *. 1.7016 - swap dup *. *. ;
::Bac_Out	1.0 - dup 2.7016 *. 1.7016 + swap dup *. *. 1.0 + ;
::Bac_InOut	1 << 1.0 <? ( Bac_In 1 >> ; ) 1.0 - Bac_Out 1 >> 0.5 + ;

::Bou_Out
	0.3636 <? ( dup *. 7.5625 *. ; )
	0.7273 <? ( 0.5454 - dup *. 7.5625 *. 0.75 + ; )
	0.9091 <? ( 0.8182 - dup *. 7.5625 *. 0.9375 + ; )
	0.9545 - dup *. 7.5625 *. 0.9844 + ;
::Bou_In		1.0 swap - Bou_Out 1.0 swap - ;
::Bou_InOut	1 << 1.0 <? ( Bou_In 1 >> ; ) 1.0 - Bou_Out 1 >> 0.5 + ;

##easet 0
Quad_In	Quad_Out Quad_InOut
Cub_In Cub_Out Cub_InOut
Quar_In Quar_Out Quar_InOut
Quin_In	Quin_Out Quin_InOut
Sin_In Sin_Out Sin_InOut
Exp_In Exp_Out Exp_InOut
Cir_In Cir_Out Cir_InOut
Ela_In Ela_Out Ela_InOut
Bac_In Bac_Out Bac_InOut
Bou_In Bou_Out Bou_InOut
0

::ease | t nro -- t'
	0? ( drop ; ) 3 << 'easet + @ ex ;

#easetm 0
Sin_In Sin_Out Sin_InOut
Exp_In Exp_Out Exp_InOut
Bac_In Bac_Out Bac_InOut
Ela_In Ela_Out Ela_InOut
Bou_In Bou_Out Bou_InOut

::easem | t nro -- t'
	$f and 0? ( drop ; ) 3 << 'easetm + @ ex ;


::catmullRom | p0 p1 p2 p3 t -- v
	>r pick2 - 1 >> 	| p0 p1 p2 v1
	>r rot over
	swap - 1 >> r>	| p1 p2 v0 v1
	2dup +			| p1 p2 v0 v1 v0+v1
	pick3 1 << - pick4 1 << +
	r@ dup dup *. *. *.	| p1 p2 v0 v1 A
	pick4 dup 1 << + neg pick4 dup 1 << + + pick3 1 << - rot -
	r@ dup *. *. +		| p1 p2 v0 A+B
	swap r> *. +
	nip + ;
