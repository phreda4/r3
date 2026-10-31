| terminal words 
| PHREDA 2021 - Updated 2025

|LIN| ^r3/lib/posix/lin-term.r3
|WIN| ^r3/lib/win/win-term.r3
|MAC| ^r3/lib/mac/mac-term.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

| KEYCODES 
::[ESC] | -- key ; key code of Escape (as returned by getch)
	$1b ;
::[ENTER] | -- key ; key code of Enter (as returned by getch)
	$d ;
::[BACK] | -- key ; key code of Backspace (as returned by getch)
	$7f ;
::[TAB] | -- key ; key code of Tab (as returned by getch)
	$9 ;
::[DEL] | -- key ; key code of Delete (as returned by getch)
	$7E335B1B ;
::[INS] | -- key ; key code of Insert (as returned by getch)
	$7E325B1B ;
::[UP] | -- key ; key code of Up arrow (as returned by getch)
	$415b1b ;
::[DN] | -- key ; key code of Down arrow (as returned by getch)
	$425b1b ;
::[RI] | -- key ; key code of Right arrow (as returned by getch)
	$435B1B ;
::[LE] | -- key ; key code of Left arrow (as returned by getch)
	$445B1B ;
::[PGUP] | -- key ; key code of Page Up (as returned by getch)
	$7e355b1b ;
::[PGDN] | -- key ; key code of Page Down (as returned by getch)
	$7e365b1b ;
::[HOME] | -- key ; key code of Home (as returned by getch)
	$485b1b ;
::[END] | -- key ; key code of End (as returned by getch)
	$465b1b ;
::[SHIFT+TAB] | -- key ; key code of Shift+Tab (as returned by getch)
	$5a5b1b ;
::[SHIFT+DEL] | -- key ; key code of Shift+Delete (as returned by getch)
	$7e323b335b1B ;
::[SHIFT+INS] | -- key ; key code of Shift+Insert (as returned by getch)
	$7E323b325B1B ;
::[SHIFT+UP] | -- key ; key code of Shift+Up arrow (as returned by getch)
	$41323b315b1b ;
::[SHIFT+DN] | -- key ; key code of Shift+Down arrow (as returned by getch)
	$42323b315b1b ;
::[SHIFT+RI] | -- key ; key code of Shift+Right arrow (as returned by getch)
	$43323b315B1B ;
::[SHIFT+LE] | -- key ; key code of Shift+Left arrow (as returned by getch)
	$44323b315B1B ;
::[SHIFT+PGUP] | -- key ; key code of Shift+Page Up (as returned by getch)
	$7e323b355b1b ;
::[SHIFT+PGDN] | -- key ; key code of Shift+Page Down (as returned by getch)
	$7e323b365b1b ;
::[SHIFT+HOME] | -- key ; key code of Shift+Home (as returned by getch)
	$48323b315b1b ;
::[SHIFT+END] | -- key ; key code of Shift+End (as returned by getch)
	$46323b315b1b ;
::[F1] | -- key ; key code of F1 (as returned by getch)
	$504f1b ;
::[F2] | -- key ; key code of F2 (as returned by getch)
	$514f1b ;
::[F3] | -- key ; key code of F3 (as returned by getch)
	$524f1b ;
::[F4] | -- key ; key code of F4 (as returned by getch)
	$534f1b ;
::[F5] | -- key ; key code of F5 (as returned by getch)
	$7E35315B1B ;
::[F6] | -- key ; key code of F6 (as returned by getch)
	$7E37315B1B ;
::[F7] | -- key ; key code of F7 (as returned by getch)
	$7E38315B1B ;
::[F8] | -- key ; key code of F8 (as returned by getch)
	$7E39315B1B ;
::[F9] | -- key ; key code of F9 (as returned by getch)
	$7E30325B1B ;
::[F10] | -- key ; key code of F10 (as returned by getch)
	$7E31325B1B ;
::[F11] | -- key ; key code of F11 (as returned by getch)
	$7E33325B1B ;
::[F12] | -- key ; key code of F12 (as returned by getch)
	$7E34325B1B ;

| [CTRL]+A : 01 ..
| [ALT]+A  : 1b A

|------- Output Buffer System -------
#outbuf | output buffer
#outbuf> 'outbuf | Current position in buffer
#endbuf |  end of outbuf

::.flush | -- ; write the output buffer to the terminal and empty it
    outbuf> outbuf - 0? ( drop ; )
	outbuf swap type
::.cl | -- ; empty the output buffer without writing it
	outbuf 'outbuf> ! ;	    

::.type | str cnt -- ; add cnt bytes of str to the output buffer (it is flushed first if they do not fit)
    endbuf outbuf> - >? ( .flush ) 
	outbuf> rot pick2 cmove
    'outbuf> +! ;
::.emit | char -- ; add a byte to the output buffer (flushes when full)
	outbuf> c!+ endbuf <? ( 'outbuf> ! ; ) 'outbuf> ! .flush ;
:.wemit | char2char1 --
	outbuf> w!+ 'outbuf> ! ;
:..emit | char1 --
	outbuf> c!+ 'outbuf> ! ;
	
::.uemit | cp -- ; add the Unicode code point cp, encoded as UTF-8, to the output buffer (invalid ones are ignored)
	$10FFFF >? ( drop ; )
	$D800 >=? ( $DFFF <=? ( drop ; ) )	| fuera de rango
	outbuf> utf8!+ endbuf <? ( 'outbuf> ! ; ) 'outbuf> ! .flush ;

::.cr | -- ; add a new line (emits LF then CR)
	$0a0d .wemit ;
::.sp | -- ; add a space
	32 ..emit ;

::.write | str -- ; add the string str to the output buffer
	count .type ;

::.print | p p .. "" -- ; add formatted text to the output buffer (same format codes as ,print; no flush)
	mark outbuf> 'here ! ,print here empty 
	endbuf <? ( 'outbuf> ! ; ) 'outbuf> !
	.flush ;

::.println | p p .. "" -- ; like .print, then a new line and a flush
	.print .cr .flush ;

::.^[ | -- ; add ESC [ (start of a terminal control sequence)
	$5b1b .wemit ;
::.[w | str -- ; add ESC [ and the string str (control sequence)
	.^[ .write ;
::.[p | p p .. "" -- ; add ESC [ and formatted text (control sequence)
	.^[ .print ;

::.nsp | n -- ; add n spaces (n >= 2: it uses the repeat sequence)
	32  
::.nch | n char -- ; add char repeated n times, with the terminal repeat sequence (n >= 2, one-byte chars only)
	..emit 1- "%db" .[p ;
	
::.ndel | n -- ; erase n characters from the cursor, the cursor does not move
	"%dX" .[p ;

::.rep | cnt "car" -- ; add the string car cnt times (multibyte safe)
	count rot ( 1? 1- pick2 pick2 .type ) 3drop ;

|--- automatic flush version
::.fwrite | str -- ; like .write and flush
	.write .flush ;
::.fprint | p p .. "" -- ; like .print and flush
	.print .flush ;

|------- Cursor Control -------
::.home | -- ; move the cursor to the top left corner
	"H" .[w ;
::.cls | -- ; clear the screen and move the cursor to the top left corner
	"H" .[w "J" .[w ;
::.at | x y -- ; move the cursor to column x, row y (1 is the first)
	"%d;%dH" .[p ;
::.col | x -- ; move the cursor to column x (1 is the first)
	"%dG" .[p ;
::.eline | -- ; erase from the cursor to the end of the line
	"K" .[w ;
|::.eline0 "1K" .[w ; | erase from start of line to cursor
|::.ealine "2K" .[w ; | borrar linea actual
::.escreen | -- ; erase from the cursor to the end of the screen
	"J" .[w ;
::.escreenup | -- ; erase from the cursor to the beginning of the screen
	"1J" .[w ;


::.showc | -- ; show the cursor
	"?25h" .[w ;
::.hidec | -- ; hide the cursor
	"?25l" .[w ;
::.blc | -- ; enable cursor blinking
	"?12h" .[w ;
::.unblc | -- ; disable cursor blinking
	"?12l" .[w ;
::.savec | -- ; save the cursor position
	"s" .[w ;
::.restorec | -- ; restore the saved cursor position
	"u" .[w ;

|------- Cursor Shapes -------
::.ovec | -- ; default cursor shape (blinking block)
	"1 q" .[w ;
::.insc | -- ; cursor shape: blinking underscore
	"3 q" .[w ;
::.blockc | -- ; cursor shape: steady block
	"2 q" .[w ;
::.underc | -- ; cursor shape: steady underscore
	"4 q" .[w ;

|------- Screen Buffer Control -------
::.alsb | -- ; switch to the alternate screen buffer and flush
	"?1049h" .[w .flush ;
::.masb | -- ; go back to the main screen buffer and flush
	"?1049l" .[w .flush ;

::.scrolloff | rows -- ; limit the scrolling region to lines 1..rows
	"1;%dr" .[p ;
::.scrollon | -- ; scrolling region back to the whole screen
	"r" .[w ;
|------- Foreground Colors -------
::.Black | -- ; set the foreground color to black
	"30m" .[w ;
::.Red | -- ; set the foreground color to red
	"31m" .[w ;
::.Green | -- ; set the foreground color to green
	"32m" .[w ;
::.Yellow | -- ; set the foreground color to yellow
	"33m" .[w ;
::.Blue | -- ; set the foreground color to blue
	"34m" .[w ;
::.Magenta | -- ; set the foreground color to magenta
	"35m" .[w ;
::.Cyan | -- ; set the foreground color to cyan
	"36m" .[w ;
::.White | -- ; set the foreground color to white
	"37m" .[w ;

::.Blackl | -- ; set the bright foreground color black
	"30;1m" .[w ;
::.Redl | -- ; set the bright foreground color red
	"31;1m" .[w ;
::.Greenl | -- ; set the bright foreground color green
	"32;1m" .[w ;
::.Yellowl | -- ; set the bright foreground color yellow
	"33;1m" .[w ;
::.Bluel | -- ; set the bright foreground color blue
	"34;1m" .[w ;
::.Magental | -- ; set the bright foreground color magenta
	"35;1m" .[w ;
::.Cyanl | -- ; set the bright foreground color cyan
	"36;1m" .[w ;
::.Whitel | -- ; set the bright foreground color white
	"37;1m" .[w ;

::.fc | n -- ; set the foreground color n of the 256 color palette
	"38;5;%dm" .[p ;

|------- Background Colors -------
::.BBlack | -- ; set the background color to black
	"40m" .[w ;
::.BRed | -- ; set the background color to red
	"41m" .[w ;
::.BGreen | -- ; set the background color to green
	"42m" .[w ;
::.BYellow | -- ; set the background color to yellow
	"43m" .[w ;
::.BBlue | -- ; set the background color to blue
	"44m" .[w ;
::.BMagenta | -- ; set the background color to magenta
	"45m" .[w ;
::.BCyan | -- ; set the background color to cyan
	"46m" .[w ;
::.BWhite | -- ; set the background color to white
	"47m" .[w ;

::.BBlackl | -- ; set the bright background color black
	"40;1m" .[w ;
::.BRedl | -- ; set the bright background color red
	"41;1m" .[w ;
::.BGreenl | -- ; set the bright background color green
	"42;1m" .[w ;
::.BYellowl | -- ; set the bright background color yellow
	"43;1m" .[w ;
::.BBluel | -- ; set the bright background color blue
	"44;1m" .[w ;
::.BMagental | -- ; set the bright background color magenta
	"45;1m" .[w ;
::.BCyanl | -- ; set the bright background color cyan
	"46;1m" .[w ;
::.BWhitel | -- ; set the bright background color white
	"47;1m" .[w ;

::.bc | n -- ; set the background color n of the 256 color palette
	"48;5;%dm" .[p ;

|------- RGB Colors (true color) | r g b --
::.fgrgb | r g b -- ; set the foreground true color (each 0..255)
	swap rot "38;2;%d;%d;%dm" .[p ;
::.bgrgb | r g b -- ; set the background true color (each 0..255)
	swap rot "48;2;%d;%d;%dm" .[p ;

|------- Text Attributes -------
::.Bold | -- ; text attribute: bold
	"1m" .[w ;
::.NBold | -- ; text attribute: bold off
	"22m" .[w ;

::.Dim | -- ; text attribute: dim
	"2m" .[w ;

::.Ital | -- ; text attribute: italic
	"3m" .[w ;
::.NItal | -- ; text attribute: italic off
	"23m" .[w ;

::.Under | -- ; text attribute: underline
	"4m" .[w ;
::.NUnder | -- ; text attribute: underline off
	"24m" .[w ;

::.Blink | -- ; text attribute: blink
	"5m" .[w ;

::.Rev | -- ; text attribute: reverse video
	"7m" .[w ;
::.NRev | -- ; text attribute: reverse video off
	"27m" .[w ;

::.Hidden | -- ; text attribute: hidden
	"8m" .[w ;
::.Strike | -- ; text attribute: strikethrough
	"9m" .[w ;
::.Reset | -- ; reset all colors and text attributes
	"0m" .[w ;

::getch | -- key ; flush the output and wait for a key, returns its code (see [ESC], [UP] ...)
	.flush
    ( inkey 0? drop 10 ms ) ;

::waitesc | -- ; wait until the ESC key is pressed
    ( getch [esc] <>? drop 10 ms ) drop ;

::waitkey | -- ; wait until any key is pressed
    ( getch 0? drop 10 ms ) drop ;
	
|---------- compati
##pad * 128 | input buffer (128 bytes) with the text read by .input
	
:.bks | adr -- adr' ; backspace de un caracter utf8
	'pad <=? ( ; )
	utf8prev 'pad max
	8 .emit 32 .emit 8 .emit ;

::.ukey | key -- key n ; n = bytes (1-4) of the UTF-8 character coded in key, 0 if it is not valid text
	32 126 in? ( 1 ; )
	dup $ff and
	$c2 $df in? ( drop dup $3fff not and $8000 =? ( drop 2 ; ) drop 0 ; )
	$e0 $ef in? ( drop dup $3f3fff not and $808000 =? ( drop 3 ; ) drop 0 ; )
	$f0 $f4 in? ( drop dup $3f3f3fff not and $80808000 =? ( drop 4 ; ) drop 0 ; )
	drop 0 ;

:.char | adr key -- adr'	
	0? ( drop ; )
	$7f =? ( drop .bks ; )
	.ukey 0? ( 2drop ; )
	pick2 'pad - over + 120 >? ( 3drop ; ) drop
	( 1? 1- >r
		dup .emit
		dup 8 >> -rot swap c!+ swap
		r> ) 2drop ;	
	
::.input | -- ; read a line of text into pad (echo, UTF-8, up to 120 bytes); Enter accepts, ESC cancels leaving pad empty
	.showc .ovec
	'pad 
	( getch $a <>? [enter] <>? [esc] <>? .char ) 
	[esc] =? ( 2drop 'pad 0 swap c! .cr .flush ; )
	drop 0 swap c! .cr .flush ;
	
:emite | char --
	$5e =? ( drop 27 .emit ; ) | ^=escape
	.emit ;
	
::.printe | p p .. "" -- ; like .print but each ^ is sent as ESC (to write control sequences)
	sprint
	( c@+ 1? emite ) 2drop ;
	
::strcpybuf | 'mem -- ; copy the output buffer (with a final 0) to 'mem and empty it
	0 .emit outbuf swap strcpy .cl ;
	
|------------------------------
::r3run | "" -- ; run the program "" with the r3 executable of the system and wait for it to end
	here
|WIN|	"r3 "
|LIN|	"./r3lin "
|MAC|	"./r3mac "	
|RPI|	"./r3rpi "	
	,s swap 34 ,c ,s 34 ,c 0 ,c 
	dup sys 'here ! ;
	
	
: |||||||||||||||||||||||||||||
	here 
	dup 'outbuf ! dup 'outbuf> !
	$3f00 +	| 16kb flush buffer
	dup 'endbuf ! 
	$ff + 'here !
	;
