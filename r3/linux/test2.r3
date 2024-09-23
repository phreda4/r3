| main filesystem
| PHREDA 2019
|------------------------
^r3/posix/console.r3
^r3/lib/mconsole.r3



:main
    .reset .cls
    "test1" .println


	mark
	here "mem/error.mem" load 0 swap c!
	here .println

	empty
waitesc
    ;

: main ;
