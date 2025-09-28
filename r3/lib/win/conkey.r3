| KEYCODES for WINDOWS
| PHREDA 2024

##[ESC]		$1B0001  ##]ESC[	$1B1001
##[ENTER]	$D001C 

##[BACK]	$8000E ##]BACK[ $8100E
##[TAB]		$9000F ##]TAB[ $9100f

##[DEL]		$53
##[UP]		$48
##[DN]		$50
##[RI]		$4d
##[LE]		$4b

##[PGUP]	$49
##[PGDN]	$51
##[HOME]	$47
##[END]		$4f
	
##[INS]		$52
##[CTRL]	$1d ##]CTRL[	$101d
##[ALT]		$38	
##[SHIFTR]	$2a ##]SHIFTR[	$102a
##[SHIFTL]	$36 ##]SHIFTL[	$1036

##[F1]	$3b
##[F2]	$3c
##[F3]	$3d
##[F4]	$3e
##[F5]	$3f
##[F6]	$40
##[F7]	$41
##[F8]	$42
##[F9]	$43
##[F10]	$44
##[F11]	$57
##[F12]	$58

::k2ascii	16 >> ;

|	$2d =? ( controlx )		| x-cut
|	$2e =? ( controlc )		| c-copy
|	$2f =? ( controlv )		| v-paste
|	$12 =? ( controle ) | E-Edit
|	$23 =? ( controlh ) | H-Help
|	$2c =? ( controlz ) | Z-Undo
|	$20 =? ( controld ) | D-Def
|	$31 =? ( controln ) | N-New
|	$32 =? ( controlm ) | M-Mode
|	$21 =? ( findmodekey )	| f-find