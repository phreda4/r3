|---- Penner animation moves

^r3/lib/math.r3

::Lineal | t -- t ; no easing (linear): t unchanged; all the easing words take and return t in fixed point 0..1.0
	;

::Quad_In | t -- t' ; t squared (quadratic) easing, slow at the start (0..1.0 in, 0..1.0 out)
	dup *. ;
::Quad_Out | t -- t' ; t squared (quadratic) easing, slow at the end
	2.0 over - *. ;
::Quad_InOut | t -- t' ; t squared (quadratic) easing, slow at the start and at the end
	1 << 1.0 <? ( Quad_In 1 >> ; ) 1.0 - Quad_Out 1 >> 0.5 + ;

::Cub_In | t -- t' ; t cubed easing, slow at the start (0..1.0 in, 0..1.0 out)
	dup dup *. *. ;
::Cub_Out | t -- t' ; t cubed easing, slow at the end
	1.0 - Cub_In 1.0 + ;
::Cub_InOut | t -- t' ; t cubed easing, slow at the start and at the end
	1 << 1.0 <? ( Cub_In 1 >> ; ) 2.0 - Cub_In 2.0 + 1 >> ;

::Quar_In | t -- t' ; t to the 4th easing, slow at the start (0..1.0 in, 0..1.0 out)
	dup *. dup *. ;
::Quar_Out | t -- t' ; t to the 4th easing, slow at the end
	1.0 - Quar_In -1.0 + neg ;
::Quar_InOut | t -- t' ; t to the 4th easing, slow at the start and at the end
	1 << 1.0 <? ( Quar_In 1 >> ; ) 1.0 - Quar_Out 1.0 + 1 >> ;

::Quin_In | t -- t' ; t to the 5th easing, slow at the start (0..1.0 in, 0..1.0 out)
	dup dup *. dup *. *. ;
::Quin_Out | t -- t' ; t to the 5th easing, slow at the end
	1.0 - Quin_In 1.0 + ;
::Quin_InOut | t -- t' ; t to the 5th easing, slow at the start and at the end
	1 << 1.0 <? ( Quin_In 1 >> ; ) 1.0 - Quin_Out 1 >> 0.5 + ;

::Sin_In | t -- t' ; sine curve easing, slow at the start (0..1.0 in, 0..1.0 out)
	1.0 swap 2 >> cos - ;
::Sin_Out | t -- t' ; sine curve easing, slow at the end
	2 >> sin ;
::Sin_InOut | t -- t' ; sine curve easing, slow at the start and at the end
	1.0 swap 1 >> cos - 1 >> ;

::Exp_In | t -- t' ; exponential curve easing, slow at the start (0..1.0 in, 0..1.0 out)
	0? ( ; ) 1.0 - 1024.0 swap pow. ;
::Exp_Out | t -- t' ; exponential curve easing, slow at the end
	1.0 =? ( ; ) -10 * 2.0 swap pow. 1.0 swap - ;
::Exp_InOut | t -- t' ; exponential curve easing, slow at the start and at the end
	1 << 1.0 <? ( Exp_In 1 >> ; ) 1.0 - Exp_Out 1 >> 0.5 + ;

::Cir_In | t -- t' ; circular curve easing, slow at the start (0..1.0 in, 0..1.0 out)
	dup *. 1.0 swap - sqrt. 1.0 swap - ;
::Cir_Out | t -- t' ; circular curve easing, slow at the end
	1.0 - dup *. 1.0 swap - sqrt. ;
::Cir_InOut | t -- t' ; circular curve easing, slow at the start and at the end
	1 << 1.0 <? ( Cir_In 1 >> ; ) 1.0 - Cir_Out 1 >> 0.5 + ;

::Ela_In | t -- t' ; elastic (the Tween.js version: it overshoots and oscillates) easing, slow at the start (0..1.0 in, 0..1.0 out)
	0? ( ; ) 1.0 =? ( ; )
    dup 1.0 - 10 * 2.0 swap pow. neg
	swap 1.1 - 2.5 *. sin *. ;
::Ela_Out | t -- t' ; elastic (the Tween.js version: it overshoots and oscillates) easing, slow at the end
	0? ( ; ) 1.0 =? ( ; )
	dup -10 * 2.0 swap pow.
	swap 0.1 - 2.5 *. sin *. 1.0 + ;
::Ela_InOut | t -- t' ; elastic (the Tween.js version: it overshoots and oscillates) easing, slow at the start and at the end
	1 << 1.0 <? ( Ela_In 1 >> ; ) 1.0 - Ela_Out 1 >> 0.5 + ;

::Bac_In | t -- t' ; back (it overshoots a little before going) easing, slow at the start (0..1.0 in, 0..1.0 out)
	dup 2.7016 *. 1.7016 - swap dup *. *. ;
::Bac_Out | t -- t' ; back (it overshoots a little before going) easing, slow at the end
	1.0 - dup 2.7016 *. 1.7016 + swap dup *. *. 1.0 + ;
::Bac_InOut | t -- t' ; back (it overshoots a little before going) easing, slow at the start and at the end
	1 << 1.0 <? ( Bac_In 1 >> ; ) 1.0 - Bac_Out 1 >> 0.5 + ;

::Bou_Out | t -- t' ; bounce easing, bounces at the end
	0.3636 <? ( dup *. 7.5625 *. ; )
	0.7273 <? ( 0.5454 - dup *. 7.5625 *. 0.75 + ; )
	0.9091 <? ( 0.8182 - dup *. 7.5625 *. 0.9375 + ; )
	0.9545 - dup *. 7.5625 *. 0.9844 + ;
::Bou_In | t -- t' ; bounce easing, bounces at the start
	1.0 swap - Bou_Out 1.0 swap - ;
::Bou_InOut | t -- t' ; bounce easing, bounces at the start and at the end
	1 << 1.0 <? ( Bou_In 1 >> ; ) 1.0 - Bou_Out 1 >> 0.5 + ;

##easet 0 | table of the easing words used by ease (entry 0 is not used, so number 1 is Quad_In); it ends with a 0
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

::ease | t nro -- t' ; apply the easing number nro to t: 0 linear, then In Out InOut of 1-3 Quad, 4-6 Cub, 7-9 Quar, 10-12 Quin, 13-15 Sin, 16-18 Exp, 19-21 Cir, 22-24 Ela, 25-27 Bac, 28-30 Bou (no range check above 30)
	0? ( drop ; ) 3 << 'easet + @ ex ;

#easetm 0
Sin_In Sin_Out Sin_InOut
Exp_In Exp_Out Exp_InOut
Bac_In Bac_Out Bac_InOut
Ela_In Ela_Out Ela_InOut
Bou_In Bou_Out Bou_InOut

::easem | t nro -- t' ; like ease with a short table, only the low 4 bits of nro count: 0 linear, then In Out InOut of 1-3 Sin, 4-6 Exp, 7-9 Bac, 10-12 Ela, 13-15 Bou
	$f and 0? ( drop ; ) 3 << 'easetm + @ ex ;


::catmullRom | p0 p1 p2 p3 t -- v ; Catmull-Rom spline value between p1 (t = 0) and p2 (t = 1.0) using the neighbours p0 and p3
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
