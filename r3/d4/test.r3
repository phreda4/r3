|main
^r3/lib/console.r3

#var1 33
#var2 0
#var3 

: 
|var1 5.0 16 *>> 
var1 8 
|/mod "%d %d" .println
mod "%d " .println
1 'var1 !
waitesc
;

|	v1 0 16 *>> "%f" .println 
|	v1 1 16 *>> "%f" .println 
|	v3 -1 16 *>> "%f" .println 
|	v3 -1 16 *>> "%f" .println 
|	v2 2.0 16 *>> "%f" .println 	
|	v2 128.0 16 *>> "%f" .println 

