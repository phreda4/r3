| Obj Model Loader to Robj
| PHREDA 2023
|-----------------------------------
|MEM 512
^r3/win/console.r3
^r3/win/sdl2gl.r3

^r3/lib/3d.r3
^r3/lib/gui.r3

^r3/util/loadobj.r3
^r3/opengl/gltext.r3


#filename * 1024
#cutpath ( $2f )
#fpath * 1024
#fname 

:getpath | 'filename 'path --
	strcpyl 2 -
	( dup c@ $2f <>? drop 1 - ) drop
	0 swap c!+ 'fname !
	;
	
|-------- file bones and weigth
#bones 

:loadbones | "" --
	here dup 'bones !
	swap load 'here !
	;
	
| 4(w) 1(bone) - x4
:,4xw | vertex -- ;
	20 * bones +
	d@+ f2fp , 1+ d@+ f2fp , 1+ d@+ f2fp , 1+ d@+ f2fp , drop ;
	
:,4xi | vertex
	20 * bones +
	4 + c@+ , 4 + c@+ , 4 + c@+ , 4 + c@+ , drop ;

:,4xw | vertex -- ;
	20 * bones +
	d@+ "%f " .print 1+ 
	d@+ "%f " .print 1+ 
	d@+ "%f " .print 1+ 
	d@+ "%f " .print  
	drop ;
	
:,4xi | vertex
	20 * bones +
	4 + c@+ "%d " .print
	4 + c@+ "%d " .print
	4 + c@+ "%d " .print
	4 + c@+ "%d " .println 
	drop ;


| MAIN
|-----------------------------------

|------------------------------------	
#GL_DEPTH_TEST $0B71
#GL_LESS $0201
#GL_CULL_FACE $0B44

#inib

: 
	"media/bvh/bones2mario" loadbones

	here bones - 20 / "%d vertices" .println
	
	( 
		.cls
		0 ( 20 <? 
	
			dup inib + "%d " .print
			dup inib + ,4xw
			dup inib + ,4xi
			1+ ) drop
	
		getch $1B1001 <>? 
			$48 =? ( -20 'inib +! ) 
			$50 =? ( 20 'inib +! )
			drop
		) drop 
	;