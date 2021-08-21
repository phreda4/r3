| print a row
^r3/win/console.r3
^r3/util/dbtxt.r3

#dbname "media/db/test.db"

#id
#titulo
#descripcion
#direccion
#telefono
#foto1

:loadfields
	'dbname loaddb-i
	0 dbfld 'id !
	1 dbfld 'titulo !
	2 dbfld 'descripcion !
	3 dbfld 'direccion !
	4 dbfld 'telefono !
	5 dbfld 'foto1 !
	;
	

	
: windows
	mark
	main
	;