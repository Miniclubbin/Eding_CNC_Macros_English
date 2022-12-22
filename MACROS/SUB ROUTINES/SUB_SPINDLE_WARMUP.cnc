;***************************************************************************************
Sub SPINDLE_WARMUP  ; Spindle Warmup 
	;---------------------------------------------------------------------------------------
	DlgMsg "Start Spindle Warmup?"
	IF [#5398 == 1]	 ;OK
		G53 G00 Z0
		M03 S#4532 	;   #4532 RPM Step 1 for Spindle Warmup
		G04 P#4533	;   #4533 Runtime Step 1 for Spindle Warmup
		M03 S#4534  ;   #4534 RPM Step 2 for Spindle Warmup
		G04 P#4535	;   #4535 Runtime Step 2 for Spindle Warmup
		M03 S#4536	;   #4536 RPM Step 3 for Spindle Warmup
		G04 P#4537	;   #4537 Runtime Step 3 for Spindle Warmup
		M03 S#4538	;   #4538 RPM Step 4 for Spindle Warmup
		G04 P#4539	;   #4539 Runtime Step 4 for Spindle Warmup
		M05
	ENDIF
ENDSUB