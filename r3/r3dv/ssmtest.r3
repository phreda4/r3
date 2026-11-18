|MEM 64
| ssmtest.r3 - prueba sin GPU de ssmulti.r3 (correr con r3lin desde la raiz del repo)
| modelo de referencia denso (q por voxel: bit 32 = ocupado, abajo el color) contra la libreria

^r3/lib/console.r3
^r3/lib/mem.r3
^r3/lib/rand.r3
^./ssmulti.r3

#ref
#cerr #cmode #cfast #cn2 #cz #cx #cl #esx #esl #esr #lbz #lbx #lbl #cc #want #wc #pk
#ext #gocc #gcol
#qn #qc #ql
#tot

:b01 | v -- 0/1
	0? ( ; ) drop 1 ;

:rf | n ci l -- adr
	'ql ! 'qc ! 'qn !
	qn 10 << qc + 5 << ql + 3 << ref + ;

:refclear | n --
	18 << ref + 0 262144 cfill ;

:inb? | v lim -- 1/0
	over -? ( 3drop 0 ; ) drop
	>=? ( drop 0 ; ) drop 1 ;

:occ? | z x l -- 1/0
	'ql ! 'qc ! 'qn !
	qn esr inb? 0? ( ; ) drop
	qc esx inb? 0? ( ; ) drop
	ql esl inb? 0? ( ; ) drop
	cn2 qn 5 << qc + ql rf @ 32 >> 1 and ;

:hid? | -- 1/0
	cz cx 1- cl occ? 0? ( ; ) drop
	cz cx 1+ cl occ? 0? ( ; ) drop
	cz 1- cx cl occ? 0? ( ; ) drop
	cz 1+ cx cl occ? 0? ( ; ) drop
	cz cx cl 1- occ? 0? ( ; ) drop
	cz cx cl 1+ occ? ;

:outside? | -- 1/0
	cx esx >=? ( drop 1 ; ) drop
	cz esr >=? ( drop 1 ; ) drop
	cl esl >=? ( drop 1 ; ) drop 0 ;

:skipcol? | -- 1/0
	wc $ffffffff and 1 =? ( drop 1 ; ) drop
	cmode 2 <>? ( drop 0 ; ) drop
	hid? ;

:perr | kind --
	'pk ! 1 'cerr +!
	cerr 8 >? ( drop ; ) drop
	cl cx cz cn2 pk "kind=%d n=%d z=%d x=%d l=%d" sprint .println ;

:cmpvox
	cz 5 << cx + 'cc !
	cn2 cc cl rf @ 'wc !
	wc 32 >> 1 and 'want !
	cmode 0 >? ( outside? 1? ( 0 'want ! ) drop ) drop
	gocc ex 'cc !
	want cc <>? ( drop 1 perr ; ) drop
	want 0? ( drop ; ) drop
	skipcol? 1? ( drop ; ) drop
	gcol ex $ffffffff and wc $ffffffff and <>? ( drop 2 perr ; ) drop ;

:eachvox | 'xt --
	'ext !
	0 ( ssm_n <?
		dup 'cn2 !
		dup ssm_size 'esr ! 'esl ! 'esx !
		32 'lbz ! 32 'lbx ! 32 'lbl !
		cfast 1? ( esr 'lbz ! esx 'lbx ! esl 'lbl ! ) drop
		0 ( lbz <? dup 'cz !
			0 ( lbx <? dup 'cx !
				0 ( lbl <? dup 'cl ! ext ex 1+ ) drop
				1+ ) drop
			1+ ) drop
		1+ ) drop ;

:cropvox
	outside? 1? ( 0 cn2 cz 5 << cx + cl rf ! ) drop ;
:refcrop
	0 'cfast !
	'cropvox eachvox ;

:libocc cn2 cz 5 << cx + cl ssm_vget b01 ;
:libcol cn2 cz 5 << cx + cl ssm_vcol@ ;

:cmplib | mode -- errors
	'cmode ! 0 'cfast ! 0 'cerr !
	'libocc 'gocc ! 'libcol 'gcol !
	'cmpvox eachvox
	cerr ;

:cmpfast | mode -- errors
	'cmode ! 1 'cfast ! 0 'cerr !
	'libocc 'gocc ! 'libcol 'gcol !
	'cmpvox eachvox
	cerr ;

|---- imagen GPU simulada
#imgp #imgt #imgc #imgpl #imgn
#uo #ub #um #ncc #ncp #ncs
:imgcolptr | -- adr
	cn2 3 << imgt + d@ cz esx * + cx + 3 << imgc + ;
:imgocc
	outside? 1? ( drop 0 ; ) drop
	imgcolptr d@ $ffffffff and cl >> 1 and ;
:imgcol
	imgcolptr 4 + d@
	dup $ffffffff and 24 >> 1 =? ( drop $ffffff and 2 << imgpl + d@ ; ) drop
	cl + 2 << imgpl + d@ ;

:mkimg
	ssm_image
	here dup 'imgp !
	dup 4 + d@ 'imgn !
	16 + dup 'imgt ! imgn 3 << +
	dup 'imgc ! imgp 8 + d@ 3 << +
	'imgpl !
	imgpl imgp 12 + d@ 2 << + 'here ! ;

:cmpimg | -- errors
	'imgocc 'gocc ! 'imgcol 'gcol !
	1 'cmode ! 1 'cfast ! 0 'cerr !
	'cmpvox eachvox
	0 ( imgn <?
		dup ssm_size
		imgt pick4 3 << + 6 + c@ $ff and <>? ( 1 'cerr +! ) drop
		imgt pick3 3 << + 5 + c@ $ff and <>? ( 1 'cerr +! ) drop
		imgt pick2 3 << + 4 + c@ $ff and <>? ( 1 'cerr +! ) drop
		3drop
		1+ ) drop
	cerr ;

:upc | off bytes 'mem --
	'um ! 'ub ! 'uo !  1 'ncc +!
	imgc uo + um ub cmove ;
:upp | off bytes 'mem --
	'um ! 'ub ! 'uo !  1 'ncp +!
	imgpl uo + um ub cmove ;
:ups | off bytes 'mem --
	'um ! 'ub ! 'uo !  1 'ncs +!
	imgt uo + um ub cmove ;

:dosync
	0 'ncc ! 0 'ncp ! 0 'ncs !
	'upc 'upp 'ups ssm_sync ;

|---- modificaciones con modelo
#tn #tc #tl #ton #tcol #rv
:rcolor | -- color
	rnd $ffffffff and 1 =? ( drop 2 ) ;
:setv | on n ci l --
	'tl ! 'tc ! 'tn ! 'ton !
	ton tn tc tl ssm_vocc!
	0 'tcol ! 0 'rv !
	ton 1? ( rcolor 'tcol ! tcol tn tc tl ssm_vcol! tcol $100000000 or 'rv ! ) drop
	rv tn tc tl rf ! ;

#rn
:randfill | cnt nsp --
	'rn !
	( 1? 1-
		rnd 3 and b01 rn rndmax 1024 rndmax 32 rndmax setv
		) drop ;

#bx0 #bz0 #bl0 #bx1 #bz1 #bl1 #bm #bc #rz #rx #rl2 #ra
:clamp31 | v -- v'
	0 max 31 min ;
:sort2 | a b -- lo hi
	2dup <? ( drop ; ) drop swap ;

:refapply
	tn rz 5 << rx + rl2 rf 'ra !
	bm 0 =? ( drop bc $ffffffff and $100000000 or ra ! ; ) drop
	bm 1 =? ( drop 0 ra ! ; ) drop
	ra @ 32 >> 1 and 1? ( drop bc $ffffffff and $100000000 or ra ! ; ) drop ;

:refbox | mode color n x0 z0 l0 x1 z1 l1 --
	'bl1 ! 'bz1 ! 'bx1 ! 'bl0 ! 'bz0 ! 'bx0 ! 'tn ! 'bc ! 'bm !
	bx0 bx1 sort2 clamp31 'bx1 ! clamp31 'bx0 !
	bz0 bz1 sort2 clamp31 'bz1 ! clamp31 'bz0 !
	bl0 bl1 sort2 clamp31 'bl1 ! clamp31 'bl0 !
	bz0 ( bz1 <=? dup 'rz !
		bx0 ( bx1 <=? dup 'rx !
			bl0 ( bl1 <=? dup 'rl2 ! refapply 1+ ) drop
			1+ ) drop
		1+ ) drop ;

#wm #wcol #wn #wa #wb #wc3 #wd #we #wf
:tbox | mode color n x0 z0 l0 x1 z1 l1 --
	'wf ! 'we ! 'wd ! 'wc3 ! 'wb ! 'wa ! 'wn ! 'wcol ! 'wm !
	wm wcol wn wa wb wc3 wd we wf refbox
	wn ssm_edit
	wm 0 =? ( drop wcol wa wb wc3 wd we wf ssm_fill ; ) drop
	wm 1 =? ( drop wa wb wc3 wd we wf ssm_erase ; ) drop
	wcol wa wb wc3 wd we wf ssm_paint ;

:stage | err "name" --
	over 'tot +! "%s: %d errores" sprint .println ;

:fsize | "file" -- bytes
	here swap load here - ;

|---- sintetico
#snp #refsv
:sizeeq | a b -- 1/0
	ssm_size 'wf ! 'we ! 'wd !
	ssm_size wf <>? ( 3drop 0 ; ) drop
	we <>? ( 2drop 0 ; ) drop
	wd <>? ( drop 0 ; ) drop 1 ;

:t_synth
	here dup 'ref ! 16777216 + 'here !
	ref 0 16777216 cfill
	here 'snp ! ssm_snapsz 'here +!
	here 'refsv ! 262144 'here +!
	1 2 rerand
	8 65536 ssm_ini
	8 8 8 ssm_add drop
	32 32 32 ssm_add drop
	5 3 4 ssm_add drop
	13 30 4 ssm_add drop
	32 1 1 ssm_add drop
	20 20 20 ssm_add drop
	6000 4 randfill
	0 cmplib "random" stage
	ssm_close
	0 cmplib "random (cerrado)" stage
	|-- rangos
	0 $aabbcc00 1 0 0 0 15 15 15 tbox
	0 $11223300 1 4 4 4 8 8 8 tbox
	2 $ff000000 1 6 0 0 20 31 31 tbox
	1 0 1 20 20 20 5 5 5 tbox
	0 $33445500 2 -3 -3 -3 40 40 40 tbox
	1 0 2 1 1 1 2 2 2 tbox
	0 cmplib "rangos" stage
	ssm_flush
	0 cmplib "rangos (flush)" stage
	|-- grabar y cargar
	"/tmp/t_a.ssv" ssm_save
	"/tmp/t_a.ssv" ssm_load
	1 cmplib "save/load" stage
	refcrop
	ssm_err "%d" sprint .println
	"/tmp/t_a.ssv" fsize "save: %d bytes" sprint .println
	"/tmp/t_b.ssv" ssm_savec
	"/tmp/t_b.ssv" fsize "savec: %d bytes" sprint .println
	"/tmp/t_b.ssv" ssm_load
	2 cmplib "savec/load" stage
	"/tmp/t_a.ssv" ssm_load
	1 cmplib "reload plano" stage
	|-- un solo sprite
	"/tmp/t_s1.ssv" 1 ssm_save1
	"/tmp/t_s1.ssv" 4 ssm_load1 "%d" sprint .println
	ref 4 18 << + ref 1 18 << + 262144 cmove
	0 cmplib "save1/load1" stage
	"/tmp/t_s2.ssv" 4 ssm_savec1
	"/tmp/t_s2.ssv" 5 ssm_load1 drop
	ref 5 18 << + ref 4 18 << + 262144 cmove
	2 cmplib "savec1/load1" stage
	ssm_close
	"/tmp/t_a.ssv" ssm_load
	4 refclear 5 refclear
	1 cmplib "reload plano 2" stage
	|-- snapshot / undo
	1 ssm_edit
	snp ssm_snap
	refsv ref 1 18 << + 262144 cmove
	0 $55667700 1 2 2 2 25 25 25 tbox
	500 1 randfill
	2 ssm_edit
	snp ssm_rest
	ref 1 18 << + refsv 262144 cmove
	0 cmplib "snapshot" stage
	|-- copiar / vaciar
	4 1 ssm_copy
	ref 4 18 << + ref 1 18 << + 262144 cmove
	4 1 sizeeq 0? ( 1 'cerr ! ) drop
	0 cmplib "copy" stage
	1 ssm_clear
	1 refclear
	0 cmplib "clear" stage
	0 $99887700 1 0 0 0 7 7 7 tbox
	0 cmplib "clear+fill" stage
	|-- tamanio
	4 8 6 2 ssm_size!
	0 cmplib "resize (datos retenidos)" stage
	"/tmp/t_c.ssv" ssm_save
	"/tmp/t_c.ssv" ssm_load
	1 cmplib "resize save/load" stage
	|-- imagen y sync
	mkimg
	cmpimg "image" stage
	300 0 randfill
	300 3 randfill
	6 7 5 0 ssm_size!
	0 $abcdef00 5 0 0 0 5 5 5 tbox
	dosync
	cmpimg "sync" stage
	ncs ncp ncc "upload cols=%d pal=%d spr=%d" sprint .println
	dosync
	ncs ncp ncc "sin cambios: cols=%d pal=%d spr=%d" sprint .println
	;

|---- archivos reales
#fn #fc #ftab #fcols #fpal #fe #fo #fx #fz #fm #fb #fa #dz #dx
:fcolor | l -- color
	fb $ffffffff and 24 >> 1 =? ( 2drop fb $ffffff and 2 << fpal + d@ ; ) drop
	fb + 2 << fpal + d@ ;

:fcol
	dz fx * dx + fo + 3 << fcols + 'fa !
	fa d@ $ffffffff and 'fm !
	fa 4 + d@ 'fb !
	0 ( 32 <?
		fm over >> 1 and
		1? ( over fcolor $ffffffff and $100000000 or
			tn dz 5 << dx + pick4 rf ! ) drop
		1+ ) drop ;

:filedec | "file" --
	here swap load drop
	here 4 + d@ 'fn ! here 8 + d@ 'fc !
	here 16 + 'ftab ! ftab fn 3 << + 'fcols ! fcols fc 3 << + 'fpal !
	ref 0 fn 18 << cfill
	0 ( fn <?
		dup 'tn !
		dup 3 << ftab + 'fe !
		fe d@ 'fo ! fe 4 + c@ $ff and 'fx ! fe 6 + c@ $ff and 'fz !
		0 ( fz <? dup 'dz !
			0 ( fx <? dup 'dx ! fcol 1+ ) drop
			1+ ) drop
		1+ ) drop ;

#fname
:tfile | "name" --
	dup 'fname !
	dup filedec
	64 2097152 ssm_ini
	ssm_load
	ssm_used fname "%s: tira local = %d colores" sprint .println
	ssm_err 1? ( "ERR carga" .println ) drop
	1 cmpfast fname "%s load" sprint stage
	"/tmp/t_f.ssv" ssm_save
	"/tmp/t_f.ssv" ssm_load
	1 cmpfast fname "%s save/load" sprint stage
	"/tmp/t_g.ssv" ssm_savec
	"/tmp/t_g.ssv" ssm_load
	2 cmpfast fname "%s savec/load" sprint stage
	"/tmp/t_g.ssv" fsize "/tmp/t_f.ssv" fsize fname fsize fname
	"%s orig=%d save=%d savec=%d" sprint .println ;

:
	t_synth
	"media/ssv/vox.ssv" tfile
	"media/ssv/dino.ssv" tfile
	"media/ssv/iti.ssv" tfile
	tot "TOTAL errores: %d" sprint .println ;
