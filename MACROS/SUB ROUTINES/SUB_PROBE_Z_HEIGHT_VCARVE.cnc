;***************************************************************************************
Sub Z_PROBE_VCARVE ; Probe for WCS Z-zero height
	;---------------------------------------------------------------------------------------
	IF [[#3501 == 1] or [#4520 < 2]]	; [Tool already Measured] or [Tool Change Mode] is 0 or 1
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------
		#4518 = 0 		; set FLAG: Move back to operation starting point (1=YES, 0=NO)
		IF [#3505 == 0] ; Tool Length Measurement not called from handwheel (1=Handwheel)
;***VARIANCE****************************************************************************
			DlgMsg "Offset actual Z0 for VCarve tolerance?" ; Generate dialog to confirm on screen
;***VARIANCE****************************************************************************
		ENDIF	
		#3505 = 0	; reset FLAG Tool Length Measurement called from handwheel (1=Handwheel)
		IF [[#5398 == 1] AND [#5397 == 0]]	; [OK button] pressed and [Simulator Mode] off
			M5							; Spindle shutdown
			msg "Probing Z height"	
			G38.2 G91 z-50 F[#4512] 	; Lower Z 50mm at [fast probe feed] until sensor triggered and stop
			IF [#5067 == 1]				; sensor triggered, value recorded to [#5063]
			    G38.2 G91 z20 F[#4513]	; Raise Z until sensor triggered at [slow probe feed] and stop
			    G90						; absolute position mode
	 		    IF [#5067 == 1]			; sensor triggered, value recorded to [#5063]
					G0 Z[#5063]			; Rapid Z move to [recorded trigger point]
;***VARIANCE****************************************************************************
					G92 Z[#4510+.1] 	; ***Offset Z by sensor height #4510 + .1mm for VCarve tolerance***
;***VARIANCE****************************************************************************
					G0 Z[#4510 + 5] 	; Rapid retract to 5mm above [sensor height]
					msg"Z-0 probe complete"
				ELSE
					G90 
					errmsg "ERROR: Sensor not activated"
				ENDIF
			ELSE	;CANCEL
			    G90 
			    DlgMsg "WARNING: No Sensor triggered! Try again?" 
			    IF [#5398 == 1] ; [OK button] pressed 
					GOSUB Z_PROBE
			    ELSE
					errmsg "Measurement failed!"
			    ENDIF
			ENDIF
		ENDIF   	
	ELSE
		#3505 = 0			; reset FLAG Tool Length Measurement called from handwheel (1=Handwheel)
		DlgMsg "ERROR - Hit OK to measure tool first" 
		IF [#5398 == 1] 	; [OK button] pressedOK pressed
	   		#4514 = #5071	; set Return point for X Pos to current MCS position
			#4515 = #5072	; set Return point for Y Pos to current MCS position
			#4516 = #5073	; set Return point for Z Pos to current MCS position
			#4518 = 1		; set FLAG: Move back to operation starting point (1=YES, 0=NO)
			GoSub TOOL_MEASURE
		ENDIF
	ENDIF
ENDSUB