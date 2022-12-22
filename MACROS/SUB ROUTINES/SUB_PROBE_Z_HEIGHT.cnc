; VARIABLES:
; #4510 Z sensor height

;***************************************************************************************
Sub Z_PROBE ; Probe for WCS Z-zero height
	;---------------------------------------------------------------------------------------
	; #185  - TEMP-Variable (Sensor error-status)
	IF [[#3501 == 1] or [#4520 < 2]]	; [Tool already Measured] or [Tool Change Mode] is 0 or 1

		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------

		#4518 = 0 						; FLAG: Move back to operation starting point (1=YES, 0=NO)
		IF [#3505 == 0] 					; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
			DlgMsg "Measure WCS Z 0" 
		ENDIF	
		#3505 = 0						; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
		IF [[#5398 == 1] AND [#5397 == 0]]			; OK button pressed and Simulator Mode off !!
			M5						; Spindle shutdown
			msg "Probing Z height"	
			G38.2 G91 z-50 F[#4512] 			; Probe towards sensor until change in signal at probe feedrate
			IF [#5067 == 1]					; IF sensor point activated
			    G38.2 G91 z20 F[#4513]			; Slowly RETRACT until sensor deactivates
			    G90								; absolute position mode
	 		    IF [#5067 == 1]				; IF sensor point activated             
				G0 Z#5063				; Rapid move to activation point
				G92 Z[#4510] 				; Overwrite current Z height with specIFied probe height

				G0 Z[#4510 + 5] 			; Rapid retract to 5mm above probe
				msg"Z-0 probe complete"
			    ELSE
				G90 
				errmsg "ERROR: Sensor not activated"
			    ENDIF

			ELSE	;CANCEL

			    G90 
			    DlgMsg "WARNING: No Sensor triggered! Try again?" 
			    IF [#5398 == 1] ;OK 
					GOSUB Z_PROBE
			    ELSE
				errmsg "Measurement failed!"
			    ENDIF
			ENDIF
		ENDIF   	
	ELSE
		#3505 = 0					; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
		DlgMsg "ERROR - Hit OK to measure tool first" 
		IF [#5398 == 1] 	;OK pressed
	   		#4514 = #5071				; set Return point for X Pos to current MCS position
			#4515 = #5072				; set Return point for Y Pos to current MCS position
			#4516 = #5073				; set Return point for Z Pos to current MCS position
			#4518 = 1				; FLAG: Move back to operation starting point (1=YES, 0=NO)
			GoSub TOOL_MEASURE
		ENDIF
	ENDIF
ENDSUB