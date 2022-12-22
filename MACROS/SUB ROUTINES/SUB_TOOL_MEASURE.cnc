;***************************************************************************************
Sub TOOL_MEASURE ; Tool Length Measurement
	;---------------------------------------------------------------------------------------
	; #4509 Distance between spindle chuck and top of tool sensor at MCS Z0 (must be negative)
	#5016 = [#5008]	; Current Tool Number
	#5017 = [#4503]	; Maximum Tool Length
	#5019 = [#4507]	; set variable to Tool Length Sensor X-Axis Position
	#5020 = [#4508]	; set variable to Tool Length Sensor Y-Axis Position
	#5021 = 0 		; Measured tool length variable

	;--------------------------------------------------
	;3DFinder - Cancel Tool Length Measurement
	;--------------------------------------------------
	;*********UNCOMMENT IF USING 3D PROBE*************
	;
	;IF [#5008 > 97]			; Tool 98 and 99 are 3D-button - no Tool Length Measurement
	;	msg "Tool is 3D-button -> Tool Length Measurement not executed"
	;	M30				; END of sequence
	;ENDIF

	; Sensor Status check -----------------------------
	GOSUB SENSOR_CHECK
	;--------------------------------------------------

    msg "Tool Length Measurement"
    dlgmsg "How long is the new tool?" "Est. Tool Length:" 5017 ; Enter estimated tool length
    IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and SimulatorMode is off
		IF [[#5017] <= 0] 				; test whether Tool Length negative
		    DlgMsg "ERROR: Tool must be >1mm long" "Est. Tool Length:" 5017
		ENDIF
	ENDIF
	IF [[#4509 + #5017 + 10] > [#4506]] ; test whether measured value higher than safe height
	    DlgMsg "Error: tool too long - could collide with sensor." "Est. Tool Length:" 5017
	ENDIF
	IF [ [#5017 <= 0] OR [[#4509 + #5017 + 10] > [#4506]] ]	;Value is negative OR tool too long for sensor height
	    errmsg "Tool Length Measurement failed"
	ENDIF

	;move to tool length sensor position
	M5
	M9							; Turn off spindle and coolant
	G53 G0 z[#4506]				; Move to Z Safe Height [MCS] 
    G53 G0 x[#5019] y[#5020]	; Move to Tool Length Sensor Position
	G53 G0 z[#4509 + #5017 + 10] ; Rapid Z to [Sensor height - max z height] + [estimated Tool Length] + 10 = negative Z distance

	; measure tool length, save results, apply Z-offset if needed
	G53 G38.2 Z[#4509] F[#4504]	 ; Probe Z to sensor height with Probe Feed #4504
	IF [#5067 == 1]				 ; Sensor is triggered
	    G91 G38.2 Z20 F[#4505]	 ; Reverse Z at [Probe feed] until trigger releases
	    G90						 ; Mode for absolute coordinates
	    IF [#5067 == 1]			 ; Sensor is triggered
			G53 G0 z[#4506]	     ; Z Safe Height [MCS]
			; -------------------Reset tool table??
			#[5400 + #5016] = 0 ;[#5053 - #4509] Save Measured Tool Length in table 
			#[5500 + #5016] = 0 ;#5018			  Tool Diameter in table save
			; determine tool length
			#5021 = [#5053 - #4509]	; Recorded tool length = sensor point - chuck height
			msg "Tool Length = " #5021
			IF [#3501 == 1] 				; Was Tool already Measured? 1=YES
			    #4502 = [#4501]				; save last tool's length
			    #4501 = [#5021]				; save new tool's length
			    #3502 = [#4501 - #4502]			; Record tool length dIFference
			    G92 Z[#5003 - #3502]		 	; set Z-0 [Current Z WCS]-[measured difference]
			    ; -------------------Update tool table??
			    ;#[5400 + #5016] = [#5053 - #4509]		;Save Measured Tool Length in table 
			    ;#[5500 + #5016] = #5018				;Tool Diameter in table save
			    ;msg "Measured Tool Length="#[5400 + #5016]" saved in Tool Number "#5016
			ELSE
			    #4501 = [#5021]				; Use current Tool Length measurement value
	   	    ENDIF
			IF [#4518 == 1] 				; FLAG: Move back to operation starting point (1=YES, 0=NO)
			    G0 G53 Z#4506				; Z Safe Height [MCS]
			    G0 G53 X#4514 Y#4515			; Move to start position
			    #4518 = 0					; FLAG: Move back to starting point (1=YES, 0=NO)
			    #3501 = 1					; FLAG: Was Tool already Measure? (1=YES, 0=NO)
			ELSE
			    IF [#4519 == 0] 			; ### 0 ### What to do after Tool Length Measurement: 0= pre defined point
					G0 G53 Z#4506				; Z Safe Height [MCS]
					G0 G53 X#4524 Y#4525			; pre defined point 
			    ENDIF
			    IF [#4519 == 1] 			; ### 1 ### What to do after Tool Length Measurement: 1= WCS 0 
					G0 G53 Z#4506				; Z Safe Height [MCS]
					G0 X0 Y0				; WCS 0 move
				ENDIF	
			    IF [#4519 == 2] 			; ### 2 ### What to do after Tool Length Measurement: 2= Tool Change Position
					G0 G53 Z#4523				; Tool Change Position Z
					G0 G53 X#4521 Y#4522			; Tool Change Position XY
			    ENDIF
			    IF [#4519 == 3] 			; ### 3 ### What to do after Tool Length Measurement: 3= MCS 0
					G0 G53 Z#4506				; Z Safe Height [MCS]
					G0 G53 X0 Y0				; MCS 0
			    ENDIF
			    ; IF [#4519 == 4] 			; ### 4 ### What to do after Tool Length Measurement: 4= Remain in place
				; ENDIF		
			ENDIF
			#4518 = 0					; FLAG: Move back to operation starting point (1=YES, 0=NO)
   	        #3501 = 1				; FLAG: Was Tool already Measure? (1=YES, 0=NO)
	   	ELSE
			errmsg "ERROR: No Sensor triggered - CONFIRM RESET"
	    ENDIF
	ELSE
		errmsg "ERROR: No Sensor triggered - Measurement failed"
	ENDIF
ENDSUB