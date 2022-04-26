| A simple 6502 emulattion benchmark
| only 11 opcodes are implemented. The memory layout is:
|  2kB RAM at 0000-07FF, mirrored throughout 0800-7FFF
| 16kB ROM at 8000-BFFF, mirrored at C000

^r3/win/console.r3

#ram * 2048 :>ram $7FF and 'ram + ;
#rom * 16384 :>rom $3FFF and 'rom + ;
| 6502 registers
#reg-a 0 #reg-x 0 #reg-y 0
#reg-s 0 #reg-pc 0 :reg-pc+ 'reg-pc +! ;
| 6502 flags
#flag-c 0 #flag-n 0 #cycle 0
#flag-z 0 #flag-v 0 :cycle+ 'cycle +! ;

:w@ dup c@ swap 1 + c@ $100 * or ;
:cs@ c@ dup 80 and? ( $100 - ) ;

:read-byte | address --
  $8000 <? ( >ram c@ ; ) >rom c@ ;
:read-word | address --
  dup $8000 <? ( >ram w@ ; ) >rom w@ ;
:dojmp | JMP aaaa
  reg-pc >rom w@ 'reg-pc ! 3 cycle+ ;
:dolda | LDA aa
  reg-pc >rom c@ 'ram + c@ dup dup 'reg-a !
  'flag-z ! $80 and 'flag-n ! 1 reg-pc+ 3 cycle+ ;
:dosta | STA aa
  reg-a reg-pc >rom c@ 'ram + c! 1 reg-pc+ 3 cycle+ ;
:dobeq | BEQ <aa
  flag-z 0? ( reg-pc >rom cs@ 1 + reg-pc+ 3 cycle+ ; ) 1 reg-pc+ 3 cycle+ ;
:doldai | LDA #aa
  reg-pc >rom c@ dup dup 'reg-a ! 'flag-z ! $80 and 'flag-n !
  1 reg-pc+ 2 cycle+ ;
:dodex | DEX
  reg-x 1 - $FF and dup dup 'reg-x ! 'flag-z ! $80 and 'flag-n !
  2 cycle+ ;
:dodey | DEY
  reg-y 1 - $ff and dup dup 'reg-y ! 'flag-z ! $80 and 'flag-n !
  2 cycle+ ;
:doinc | INC aa
  reg-pc >rom c@ 'ram + dup c@ 1 + $FF and dup rot rot swap c! dup
  'flag-z ! $80 and 'flag-n ! 1 reg-pc+ 3 cycle+ ;
:doldy | LDY aa
  reg-pc >rom c@ dup dup 'reg-y ! 'flag-z ! $80 and 'flag-n !
  1 reg-pc+ 2 cycle+ ;
:doldx | LDX #aa
  reg-pc >rom c@ dup dup 'reg-x ! 'flag-z ! $80 and 'flag-n !
  1 reg-pc+ 2 cycle+ ;
:dobne | BNE <aa
  flag-z 1? ( reg-pc >rom cs@ 1 + reg-pc+ 3 cycle+ ; ) 1 reg-pc+ 3 cycle+ ;
:6502emu | cycles --
  ( cycle >=?
    reg-pc >rom c@ 1 reg-pc+
    $4C =? ( dojmp )
	$A5 =? ( dolda )
    $85 =? ( dosta )
	$F0 =? ( dobeq )
    $D0 =? ( dobne )
	$A9 =? ( doldai )
    $CA =? ( dodex )
	$88 =? ( dodey )
    $E6 =? ( doinc )
	$A0 =? ( doldy )
    $A2 =? ( doldx )
	drop ) drop ;

#testcode (
  $A9 $00	| start: LDA #0
  $85 $08	|        STA 08
  $A2 $0A	|        LDX #10
  $A0 $0A	| loop1: LDY #10
  $E6 $08	| loop2: INC 08
  $88		|        DEY
  $D0 $FB	|        BNE loop2
  $CA		|        DEX
  $D0 $F6	|        BNE loop1
  $4C $00 $80  |   JMP start
)

:init-vm
	0 ( $13 <?
		dup 'testcode + c@ over 'rom + c!
		1 + ) drop
	0 'cycle ! $8000 'reg-pc ! ;

:bench6502
	0 ( $100 <?
		init-vm 6502 6502emu
		1 + ) drop ;

:
	.cls
	" ejecutando 6502..." .print cr

	msec

	bench6502

	msec swap - " resultado %d ms " .print cr
	" Presione <ENTER> para continuar..." .print
	.input
	;

