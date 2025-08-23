| memavx.dll
| PHREDA 2025
^r3/lib/win/kernel32.r3

#rgb32_to_planar_f32_avx2_aligned_p
::rgb32_to_planar_f32_avx2_aligned rgb32_to_planar_f32_avx2_aligned_p sys3 drop ;

: 
	".\\dll" SetDllDirectory
	"memavx.dll" loadlib 
	dup "rgb32_to_planar_f32_avx2_aligned" getproc 'rgb32_to_planar_f32_avx2_aligned_p !
	drop
	"" SetDllDirectory
	;