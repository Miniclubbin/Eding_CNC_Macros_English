;***************************************************************************************
Sub TOOL_MEASURE_WEAR ; Tool Wear Detection
	;---------------------------------------------------------------------------------------
	; #185  - TEMP-Variable (Sensor error-status)
	; #4509 Distance between spindle chuck and top of tool sensor at MCS Z0 (must be negative)     	(Tool Length Measurement)
	; #5021 - Gemessene Tool Length aus the vorherigen Measurement
	;

	; #4529 = 0
	; IF [#4529 == 1]			 					; #4529 FLAG whether Automatic Tool Wear is enabled

	IF [#3501 == 1]								; FLAG (Was Tool already Measured? 1=YES)
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------

		msg "Tool Wear Detection"
		M5 M9
		G53 G0 z[#4506]							; Safe Height 
		G53 G0 y[#5020]  						; Tool Change Position    
		G53 G0 x[#5019]							; Tool Change Position
		G53 G0 z[#4509 + #5017 + 10]

		G53 G38.2 Z[#4509] F[#4504] 
		IF [#5067 == 1]							; When Sensor is triggered
			G91 G38.2 Z20 F[#4505] 
			G90
			IF [#5067 == 1]						; When Sensor is triggered, is Probe point in #5053 saved
				#4501 = [#5053 - #4509]				; recording of actual Tool Length = probe point  - chuck height
				G00 G53 z#4506
				IF [[[#5021 + #4528] > [#4501]]  and [[#5021 - #4528] < [#4501]]]
					msg "Okay"
					msg " dimensional deviation:" [#5021 - #4501]	
					
				ELSE
					#3504 = 0				; FLAG whether Break Check from automatic initiated was 1=automatic
					G53 G0 Z[#4523]				; Safe Height
					G53 G0 X[#4521] 			; Manuelle Tool Change Position X XYchange
					G53 G0 Y[#4522]				; Manuelle Tool Change Position Y XYchange
					Dlgmsg "Tool worn, continue?" " dimensional deviation:" 4501	
					IF [#5398 == 1] ;OK
						Dlgmsg "WARNING: Job is continued"	
					ELSE
						#3504 = 0			; FLAG whether Break Check from automatic initiated was 1=automatic
						errmsg "Tool worn, abort"
					ENDIF
				ENDIF

				IF [#3504 == 0]					; FLAG whether Break Check from automatic initiated was 1=automatic
					IF [#4519 == 0] 			; What to do after Tool Length Measurement 0= pre defined point
						G0 G53 Z#4506				; Safe Z 
						G0 G53 X#4524 				; pre defined point XYchange
						G0 G53 Y#4525				; pre defined point XYchange
					ENDIF
			
					IF [#4519 == 1] 			; What to do after Tool Length Measurement 1= WCS 0 move 
						G0 G53 Z#4506				; Safe Z 
						G0 X0 					; WCS 0 move move XYchange
						G0 Y0 					; WCS 0 move move XYchange
					ENDIF
					
					IF [#4519 == 2] 			; What to do after Tool Length Measurement 2= Tool Change Position move
						G0 G53 Z#4523				; Tool Change Position Z
						G0 G53 X#4521 				; Tool Change Position X
						G0 G53 Y#4522				; Tool Change Position Y
					ENDIF

					IF [#4519 == 3] 			; What to do after Tool Length Measurement 3= MCS 0 move
						G0 G53 Z#4506				; Safe Z 
						G53 X0 					; MCS 0 move XYchange
						G53 Y0 					; MCS 0 move XYchange
					ENDIF

					IF [#4519 == 4] 			; What to do after Tool Length Measurement 4= Remain in place		
					ENDIF
				ENDIF					

			ELSE
				#3504 = 0					; FLAG whether Break Check from automatic initiated was 1=automatic
				errmsg "ERROR: No Sensor triggered"
			ENDIF
		ELSE
			#3504 = 0						; FLAG whether Break Check from automatic initiated was 1=automatic
			errmsg "ERROR: No Sensor triggered"
		ENDIF

	ELSE
	   DlgMsg "Tool was not Measured"
	ENDIF
	#3504 = 0								; FLAG whether Break Check from automatic initiated was 1=automatic

   ; ELSE
   ;	DlgMsg "Break Check not activated"
   ; ENDIF

ENDSUB