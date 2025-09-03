| memavx.dll
| PHREDA 2025
^r3/lib/win/kernel32.r3

#rgb32_to_planar_f32_avx2_aligned_p
::rgb32_to_planar_f32_avx2_aligned rgb32_to_planar_f32_avx2_aligned_p sys3 drop ;
#bgr32_to_planar_f32_avx2_aligned_p
::bgr32_to_planar_f32_avx2_aligned bgr32_to_planar_f32_avx2_aligned_p sys3 drop ;
#convert_rgb_to_float32_p
::convert_rgb_to_float32 convert_rgb_to_float32_p sys3 drop ;
#f32_to_q16_16_p
::f32_to_q16_16 f32_to_q16_16_p sys3 drop ;
#q16_16_to_f32_p
::q16_16_to_f32 q16_16_to_f32_p sys3 drop ;

: 
	"dll/memavx.dll" loadlib 
	dup "rgb32_to_planar_f32_avx2_aligned" getproc 'rgb32_to_planar_f32_avx2_aligned_p !
	dup "bgr32_to_planar_f32_avx2_aligned" getproc 'bgr32_to_planar_f32_avx2_aligned_p !
	dup "convert_rgb_to_float32" getproc 'convert_rgb_to_float32_p !
	dup "f32_to_q16_16" getproc 'f32_to_q16_16_p !
	dup "q16_16_to_f32" getproc 'q16_16_to_f32_p !
	drop
	;