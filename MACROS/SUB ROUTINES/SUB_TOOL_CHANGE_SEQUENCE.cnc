;***************************************************************************************
sub change_tool ; TOOL CHANGE SEQUENCE
	;---------------------------------------------------------------------------------------
    #5015 = 0	; set FLAG: Tool Change not yet executed
    M5 M9	; Spindle off, cooling off
    IF [#5397 == 0]	; Simulator Mode off (0= off)
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------

		;---------------------------------------------------------------------------------------
		; 0 = Ignore Toolchange
		;---------------------------------------------------------------------------------------
		IF [[#4520] == 0] 			; Tool Change Type  0= Do nothing, 1 = Move to WCS0, 2= Move to WCS0 + Measure 
			#5015 = 1				; set FLAG tool changed 1=Yes
		ENDIF

		;---------------------------------------------------------------------------------------
		; 1 = Move to WCS0
		;---------------------------------------------------------------------------------------
		IF [[#4520] == 1] 			; Tool Change Type  0= Do nothing, 1 = Move to WCS0, 2= Move to WCS0 + Measure 
			#3503 = 1				; Is Tool already inserted?  1=Yes
			IF [[#5011] == [#5008]]  ;IF new tool matches Current Tool
				Dlgmsg "Tool is already inserted. Measure tool?"
				IF [#5398 == 1] ;OK pressed
					#3503 = 1
				ELSE
					#3503 = 0
					M00
				ENDIF
			ENDIF
			IF [#3503 == 1] 
				G53 G0 Z[#4523]			; Safe Height
				G53 G0 X[#4521] Y[#4522]	; Tool Change Position X Y
				Dlgmsg "Please insert tool" "Current Tool Number:" 5008" New Tool Number:" 5011
				IF [#5398 == 1] ;OK pressed
					IF [#5011 > 99] 
						Dlgmsg "Tool Number Incorrect: Please enter Tool Number 1-99"
						IF [#5398 == 1] ;OK pressed
							gosub change_tool
						ELSE
							errmsg "Tool Change failed"
						ENDIF
					ELSE
						#5015 = 1		; Tool Change executed 1=Yes
					ENDIF
				ELSE
					errmsg "Tool Change failed"
				ENDIF
			ENDIF
		ENDIF		

		;---------------------------------------------------------------------------------------
		; 2= Move to WCS0 + Measure 
		;---------------------------------------------------------------------------------------
	
		IF [[#4520] == 2] ; Tool Change Type  0= Do nothing, 1 = Move to WCS0, 2= Move to WCS0 + Measure 
			#3503 = 1 ; Tool Number already inserted  1=Yes
			IF [[#5011] == [#5008]] 
				Dlgmsg "Tool is already inserted. Measure tool?"
				IF [#5398 == 1] ;OK
					#3503 = 1
				ELSE
					#3503 = 0
					M00
				ENDIF
			ENDIF
			IF [#3503 == 1] 
				IF [[#5008 > 0] AND [#4529 == 1]]	; Current Tool Number larger than 0 and Break Check activated
					#3504 = 1			; FLAG whether Break Check from automatic initiated was 1=automatic
					GOSUB TOOL_MEASURE_WEAR			; Break Check called
					#3504 = 0			; FLAG whether Break Check from automatic initiated was 1=automatic
				ELSE
					msg "Break Check not executed"
				ENDIF
				G53 G0 Z[#4523]				; Safe Height
				G53 G0 X[#4521] Y[#4522]		; Tool Change Position X Y
				Dlgmsg "Please insert tool" "Current Tool Number:" 5008 " New Tool Number:" 5011
				IF [#5398 == 1] ;OK pressed
					IF [#5011 > 99]
						Dlgmsg "Tool Number Incorrect: Please enter Tool Number 1-99" " New Tool Number:" 5011
						IF [#5398 == 1] ;OK pressed
					 	    IF [#5011 > 99]
								errmsg "Tool Number Incorrect -> Tool Change failed"
						    ENDIF
						ELSE
						    errmsg "Tool Change failed"
						ENDIF
					ENDIF
					#5015 = 1			; Tool Change executed 1=Yes
				ELSE
				   	errmsg "Tool Change failed" 
				ENDIF
			ENDIF
		ENDIF
		
		;---------------------------------------------------------------------------------------	

		IF [[#5015] == 1]    
			msg "Tool " #5008" changed to Tool " #5011 " "		
	        M6 T[#5011]				; New Tool Number set
			IF [#4520 == 2] 			; Tool Change Type  0= Do nothing, 1 = Move to WCS0, 2= Move to WCS0 + Measure 
			    gosub TOOL_MEASURE			; Tool Length Measurement called  [WARNING - Must occur after M6 T.. command is called]
			ENDIF
			#5015 = 0				; Tool Change executed 1=Yes
		ENDIF
		;G01
    ENDIF ; SIMULATOR Mode
ENDSUB
