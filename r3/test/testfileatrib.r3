^r3/win/console.r3
^r3/lib/parse.r3
^r3/lib/jul.r3

|typedef struct _WIN32_FILE_ATTRIBUTE_DATA {
|DWORD dwFileAttributes; // attributes (the same as for the function GetFileAttributes)
|FILETIME ftCreationTime; // creation time
|FILETIME ftLastAccessTime; // last access time
|FILETIME ftLastWriteTime; // last modification time
|DWORD nFileSizeHigh; // the high DWORD of the file size (it is zero unless the file is over four gigabytes)
|DWORD nFileSizeLow; // the low DWORD of the file size
|} WIN32_FILE_ATTRIBUTE_DATA;

| atrib creation access write size
#info [ 0 ] 0 0 0 0
	
:swapd
	dup 32 >> swap 32 << or ;

| 133114747139027354 28/10/2022 11:51
| 133114747234026572 28/10/2022 11:52
:todate | nro --
	86400000000 / | segundos>days
	23058135 + | julian from 1601-01-01
	10 /
	jul2date
	"%d %d %d" .println
	;
	
:fileinfo | "" --
	dup .println 
	0 'info GetFileAttributesEx 
	0? ( drop ; )
	"%d) " .print
	'info d@+ " atrib: %h" .println
	@+ todate
	@+ todate 
	@+ todate 
	@+ swapd "size: %d" .println
	drop
	.cr
	;
	
		
:main
	.cls
	"test getFileAtributesEx" .println
	
	"main.r3" fileinfo
	"autotv/programa.txt" fileinfo
	waitesc ;
	
: main ;