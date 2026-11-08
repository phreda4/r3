|MEM 64
| vox2xt.r3 - TUI para elegir una carpeta de .vox (bajo media/ssv) y convertirla con vox2x.r3
| genera <carpeta>.ssv y <carpeta>.txt al lado de la carpeta (media/ssv/vox -> media/ssv/vox.ssv)
| ENTER/click: convertir la carpeta marcada   ESC: salir

^r3/util/tui.r3
^r3/util/filedirs.r3
^r3/r3dv/vox2x.r3

#root "media/ssv"
#vsel 0 0
#fpath * 512
#lastmsg * 256

:fpath! | str --		; fpath = root/str sin la / final
	'root "%s/%s" sprint 'fpath strcpy
	'fpath count 1- 'fpath +
	dup c@ $2f =? ( drop 0 swap c! ; ) 2drop ;

:convert
	vsel flTreePath
	dup c@ 0? ( 2drop ; ) drop
	fpath!
	.masb .cls
	'fpath "%s" .println .cr
	mark
	'fpath voxdir
	'fpath voxconvert
	empty
	.cr .bblue .white " Cualquier tecla para volver... " .write .reset .flush
	waitkey
	.alsb .flush
	'fpath "%s.ssv" sprint 'lastmsg strcpy
	tuR! ;

:screen
	.reset .hidec .bblack .cls
	1 flxN
	bg3 fhome " vox2xt  .vox -> .ssv" .write .eline
	1 flxS
	bg3 fhome
	fPr " ENTER" .write fTx " convertir " .write
	fPr " ESC" .write fTx " salir " .write
	fMu 'lastmsg .write
	.eline
	flxRest
	tuWin $1 " Carpetas en media/ssv " .wtitle
	1 1 flpad
	'vsel uiDirs tuTree
	uikey
	[enter] =? ( convert )
	[esc] =? ( tuiexit )
	$3 =? ( tuiexit )
	$11 =? ( tuiexit )
	drop ;

:main
	mark
	'root flScanDir
	'screen onTui ;

:
	.alsb main .masb .free ;
