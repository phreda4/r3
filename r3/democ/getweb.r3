| Test WININET
| PHREDA 2021

^r3/lib/win/inet.r3
^r3/lib/console.r3

#cnt

: 
"http://www.google.com" 0 here openurl
dup here - 'cnt !
0 swap c!

.cls
here count type
.cr
cnt " largo:%d " .println
.input
;
