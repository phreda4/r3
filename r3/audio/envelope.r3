^r3/lib/console.r3

#attack_time   0.1   | 100ms attack
#decay_time    0.15  | 150ms decay  
#sustain_level 0.7   | 70% sustain level
#release_time  0.3   | 300ms release


#value | ($f-estate)|(value)

#rel_rate
#sus_level
#dec_rate
#att_rate

:IMS2TICKS 	1000.0 44100 */ ;
	
::ADSR! | A D S R -- | ms ms level ms
	1? ( IMS2TICKS ) 'rel_rate !
	'sus_level !
	1? ( IMS2TICKS ) 'dec_rate !
	1? ( IMS2TICKS ) 'att_rate !
	;
		
	