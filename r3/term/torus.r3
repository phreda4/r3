| DONUT3D.R3  —  Rotating ASCII torus for r3forth
| Algorithm: "donut.c" by Andy Sloane, adapted to r3forth
|
^r3/lib/console.r3
^r3/lib/math.r3

| ---- screen dimensions (edit to match your terminal) ------
#SW  78    | columns
#SH  24    | rows

| Buffers must be >= SW*SH bytes.
#zbuf * 2048   | depth per pixel (byte; 0 = not drawn yet)
#cbuf * 2048   | output character per pixel (byte)

| ---- rotation angles (16.16 turns, kept in 0..65535) ------
#angA 0   | spin around axis A
#angB 0   | tilt around axis B

| ---- torus geometry (all 16.16 fixed point) ---------------
| R1 = tube radius = 1.0
| R2 = ring center radius = 2.0
| K2 = distance from eye to torus center
| K1 = horizontal projection scale
#fp1	0.8 
#fp2	2.2 
#K2		25.0 
#K1		150.0

| ---- intermediate values used during sample computation ---
#ct #st    | cos/sin(theta)
#cp #sp    | cos/sin(phi)
#cxr       | R2 + R1*cos(theta)  (the "big circle" radius for this theta)
#px #py #pz       | 3D point on torus (16.16)
#rx #ry #rz       | point after rotation (16.16)
#nx #ny #nz       | surface normal (16.16)
#rnx #rny #rnz    | normal after rotation (16.16)

| ---- rotation trig cached per frame -----------------------
#cosA #sinA #cosB #sinB

| ---- ASCII luminance ramp (12 levels, dark to bright) -----
#lc ".,-~:;=!*#$@"

| ===== helper words =========================================

:clrbufs | --
    'zbuf 0 SW SH * cfill   | all depths = 0 (undrawn)
    'cbuf 32 SW SH * cfill ; | all chars  = space

:cachetrig | --
    angA cos 'cosA !   angA sin 'sinA !
    angB cos 'cosB !   angB sin 'sinB ! ;

| ===== one torus sample =====================================
:dotsample | theta phi --
	dup cos 'cp ! sin 'sp !
    dup cos 'ct ! sin 'st !

    | ---- point on torus surface ----
    ct fp1 *. fp2 + 'cxr !

    cxr cp *. 'px !   | x = cxr * cos(phi)
    cxr sp *. 'py !   | y = cxr * sin(phi)
    st        'pz !   | z = R1*sin(theta) = sin(theta) (R1=1.0)

    | ---- outward surface normal ----
    ct cp *. 'nx !
    ct sp *. 'ny !
    st       'nz !

    | ---- rotate point by angA (around the Z/Y plane) ----
    px cosA *. pz sinA *. + 'rx !
    pz cosA *. px sinA *. - 'rz !
    py 'ry !

    | ---- then rotate by angB (around the X axis) ----------
    ry cosB *. rz sinB *. - 
    rz cosB *. ry sinB *. + 
	'rz ! 'ry !

    | ---- same rotations for the normal --------------------
    nx cosA *. nz sinA *. + 'rnx !
    nz cosA *. nx sinA *. - 'rnz !
    ny 'rny !

    rny cosB *. rnz sinB *. -
    rnz cosB *. rny sinB *. + 
	'rnz ! 'rny !

	1.0 k2 rz + /. |ooz
	0? ( drop ; ) 
	k1 *.
	dup rx *. int. sw 2/ +
	0 <? ( 2drop ; ) sw >=? ( 2drop ; )  
	swap ry *. int. sh 2/ +
	0 <? ( 2drop ; ) sh >=? ( 2drop ; ) 
	sw * + >a

	rz $ff 1.0 */ 1 max 254 min   | depth byte
    a> 'zbuf + c@ $ff and <=? ( drop ; ) a> 'zbuf + c!

    rnz $f 1.0 */ 0 max 11 min
    'lc + c@ a> 'cbuf + c!   | store in char buffer
    ;

:renderframe | --
	clrbufs
	cachetrig
	0 ( 1.0 <?
		0 ( 1.0 <?
			2dup dotsample
			0.015 + ) drop
		0.015 + ) drop 
	;

| ===== send cbuf to terminal ================================
:flushscreen | --
    1 1 .at
    0 ( SH <?
        dup SW * 'cbuf + SW .type   | write one row of chars
        .cr
        1+ ) drop
    .flush ;

:spin | --
    0.008 'angA +! 0.012 'angB +! ;

:
    .alsb .hidec .cls
    0 'angA ! 0 'angB !
    ( inkey [esc] <>? drop	| loop until ESC
        renderframe
        flushscreen
        spin
        80 ms
        ) drop
    .cls .masb .showc
    ;
