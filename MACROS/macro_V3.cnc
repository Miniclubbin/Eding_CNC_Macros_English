;***************************************************************************************
;DEC_V3
;EDING CNC
;MACRO CNC V2.1e.1 Without ATC
;Derived from SOROTEC
;Translated by MiniClubbin
;***************************************************************************************

;Variables used

	;   #3500 INIT
	;   #3501 FLAG (Has Tool already been measured? 1=YES)
	;   #3502 FLAG Only needed for calculation
	;   #3503 FLAG Yes / No in Dialog
	;   #3504 FLAG whether Break Check called by automatic 1=automatic
	;   #3505 FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
	;   #3510 FLAG Tool Change initiated from GUI (1= initiated from GUI)
	;
; Parameter for Type of Tool Length Sensor
	;---------------------------------------------
	;   #4400 Tool Length Sensor-Type (0= NOpen, 1= NClosed)
	;   #4500 NOT USED
; Parameter for Tool Length Measurement
	;------------------------------------- 
	;   #4501 Current Tool Length
	;   #4502 Current Tool Length
	;   #4503 Maximum Tool Length
	;   #4504 Fast probing feed (mm/min)
	;   #4505 Slow probing feed for exact measurement (mm/min)
	;   #4506 Safe Height in MCS
	;   #4507 Position for the X Axis
	;   #4508 Position for the Y Axis							 
	;   #4509 Distance between spindle chuck and top of tool sensor at MCS Z0 (must be negative)
; Parameter for Z-0 point Measurement
	;-------------------------------------- 
	;   #4510 Probe sensor activation height (MM)
	;   #4511 Clearance Height
	;   #4512 Fast feed for probing (mm/min)
	;   #4513 Slow probing feed for exact measurement (mm/min)
; Parameter for Tool Length Measurement
	;-------------------------------------
	;   #4514 Mark Return point for X Pos
	;   #4515 Mark Return point for Y Pos
	;   #4516 Mark Return point for Z Pos
	;   #4517 FLAG (No tool chosen)
	;   #4518 FLAG: Move back to operation starting point (1=YES, 0=NO)
	;   #4519 What to do after Tool Length Measurement: 
	;		0= move to predefined point 
	;		1= move to WCS 0 
	;		2= move to Tool Change Position 
	;		3= move to MCS 0 
	;		4= Remain in place
	;   #4520 Tool Change Type 
	;		0= Do nothing 
	;		1= Only move WPos 
	;		2= Move WPos + Measure 
	;   #4521 (TYP 0) Tool Change Position  X 
	;   #4522 (TYP 0) Tool Change Position  Y
	;   #4523 (TYP 0) Tool Change Position  Z
	;   #4524 Position X after Tool Length Measurement   
	;   #4525 Position Y after Tool Length Measurement
	;   #4526 Position Z after Tool Length Measurement
	;UNUSED #4527 Distance between spindle chuck and top of tool sensor at MCS Z0 (must be negative)
	;   #4528 Allowable Tolerance for Tool Wear Control
	;   #4529 FLAG whether Automatic Tool Wear Control is enabled
	;UNUSED #4530 FLAG whether Cone Check is enabled
	;UNUSED #4531 Cone height above sensor
; Parameter for Spindle-Warmup
	;-------------------------------- 
	;   #4532 RPM Step 1 for Spindle Warmup
	;   #4533 Runtime Step 1 for Spindle Warmup
	;   #4534 RPM Step 2 for Spindle Warmup
	;   #4535 Runtime Step 2 for Spindle Warmup
	;   #4536 RPM Step 3 for Spindle Warmup
	;   #4537 Runtime Step 3 for Spindle Warmup
	;   #4538 RPM Step 4 for Spindle Warmup
	;   #4539 Runtime Step 4 for Spindle Warmup
	;	#4540 to #4543 Empty for more Spindle Warmup levels
; Parameter for 3D-finder
	;------------------------- 
	;   #4544 3D-finder Sensor-Type (0= Open, 1= Closed)
	;   #4545 3D-finder probe length (Tool Length)
	;   #4546 3D-finder Tip radius
	;   #4547 3D-finder Radius-Offset
	;
	;   #4548 3D-finder Feed to locate probe (mm/min)
	;   #4549 3D-finder Slow probing feed for exact measurement (mm/min)
; Parameter for Workpiece probe (SOROTEC)
	;--------------------------------------------
	; 3D EdgeFinder Probing
	;   #4550 3D-finder 0 point probing direction
	;   #4551 3D-finder 0 point offset X+
	;   #4552 3D-finder 0 point offset X-
	;   #4553 3D-finder 0 point offset Y+
	;   #4554 3D-finder 0 point offset Y-
	;   #4560 - 3D-finder Spindle offset accounted for? (1= Yes, 0= No)
	;   #4561 - 3D-finder Spindle offset X
	;   #4562 - 3D-finder Spindle offset Y
	;   #4563 - UNUSED
	;   #4564 - UNUSED
	;   #4565 - UNUSED
	;   #4566 - UNUSED
	;   #4600 Reserved for ATC
; Parameter for Position after Homing Sequence
	;------------------------------------------
	;   #4631 Position in X after the Homing Sequence
	;   #4632 Position in Y after the Homing Sequence
	;   #4633 Position in Z after the Homing Sequence
; SYSTEM VARIABLES
	;------------------
	;   #5001 Current X Pos (WCS)
	;   #5002 Current Y Pos (WCS)
	;   #5003 Current Z Pos (WCS)
	;   #5004 Current A Pos (WCS)
	;   #5005 Current B Pos (WCS)
	;   #5006 Current C Pos (WCS)
	;   #5008 Current Tool Number
	;   #5010 Current Tool Length
	;   #5011 New Tool Number
	;   #5015 Tool Change-Process (0= Change not executed, 1= Change was executed)
	;   #5016 =  Current Tool Number
	;   #5017 =  Maximum Tool Length
	;   #5019 =  Tool Length Sensor Position X-Axis
	;   #5020 =  Tool Length Sensor Position Y-Axis
	;   #5053 Sensor-Activation point Z Pos (MCS) when sensor input changes status
	;   #5061 Sensor-Activation point X Pos (WCS)
	;   #5062 Sensor-Activation point Y Pos (WCS)
	;   #5063 Sensor-Activation point Z Pos (WCS)
	;   #5064 Sensor-Activation point A Pos (WCS)
	;   #5065 Sensor-Activation point B Pos (WCS)
	;   #5066 Sensor-Activation point C Pos (WCS)
	;   #5067 Sensor Impulse:  1 = when sensor input changes status
	;   #5068 Sensor Status: 0 = closed, 1 = open (When sensor is set as NO-normal open)
	;   #5071 Current X Pos (MCS)
	;   #5072 Current Y Pos (MCS)
	;   #5073 Current Z Pos (MCS)
	;   #5074 Current A Pos (MCS)
	;   #5075 Current B Pos (MCS)
	;   #5076 Current C Pos (MCS)
	;   #5113 Positive Limit Z (MCS)
	;   #5380 Query IF machine is in Simulation Mode [0=No Normal Mode,  1=Yes Simulation Mode]
	;   #5397 Query IF machine is in SIMULATOR mode [0 = no normal mode] [1 = yes SIMULATOR mode]
	;   #5398 DlgMsg Return-Value [1=OK,  -1=CANCEL]
	;   #5399 Return-Value for functions M55 and M56

;---------------------------------------------------------------------------------------

;***************************************************************************************
; INITIALIZE
	IF [#3500 == 0]  ; IF [Initialize] is 0  proceed
		#3500 = 1			;set FLAG [initialized]
		IF [#4504 == 0]   	
			#4504 =50	; set [TLO Fast probing feed] (mm/min)
		ENDIF
		IF [#4505 == 0]   	
			   #4505 =20  	; set [TLO Slow probing feed] for exact measurement (mm/min)  
		ENDIF
		IF [#4511 == 0]   	
		   	#4511 =10	; set [probe Clearance height]	
		ENDIF
		IF [#4512 == 0]   	
			#4512 = 50  	;set [Z0 Fast probing feed] (mm/min)
		ENDIF  
		IF [#4513 == 0]   	
			#4513 =20  	; set [Z0 Slow probing feed] for exact measurement (mm/min)
		ENDIF
	ENDIF
;---------------------------------------------------------------------------------------

;***************************************************************************************
; User Macros
;***************************************************************************************
Sub user_1 ; Probe for WCS Z-zero height
	GOSUB Z_PROBE	
ENDSUB
;***************************************************************************************
Sub user_2 ; Tool Length Measurement
	GOSUB TOOL_MEASURE
ENDSUB
;***************************************************************************************
Sub user_3 ; Tool change
	GOSUB TOOL_CHANGE_DLG
ENDSUB
;***************************************************************************************
Sub user_4 ; Move to MCS 0 (Home)
	GOSUB MOVE_MCS0
ENDSUB
;***************************************************************************************
Sub user_5 ; Tool Number Update
	GOSUB TOOL_NBR_UPDATE
ENDSUB
;***************************************************************************************
Sub user_6 ; Probe for Z0, offset by .1mm for VCarve tolerance
	;---------------------------------------------------------------------------------------
   	msg "Sub Z_PROBE_VCARVE"
	goSub Z_PROBE_VCARVE
ENDSUB
;***************************************************************************************
Sub user_7 ; Sub MOVE_WCS0_G54 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
	GOSub MOVE_WCS0_G54 ; Move to WCS XY0 Z5
ENDSUB
;***************************************************************************************
Sub user_8 ; Sub MOVE_WCS0_G55 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
	GOSub MOVE_WCS0_G55 ; Move to WCS XY0 Z5
ENDSUB
;***************************************************************************************
Sub user_9 ; Sub MOVE_WCS0_G56 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
	GOSub MOVE_WCS0_G56 ; Move to WCS XY0 Z5
ENDSUB
;***************************************************************************************
Sub user_10 ; Sub MOVE_WCS0_G57 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
	GOSub MOVE_WCS0_G57 ; Move to WCS XY0 Z5
ENDSUB
;***************************************************************************************
Sub user_11 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_11"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_12 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_12"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_13 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_13"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_14 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_14"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_15 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_15"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_16 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_16"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_17 ; NONE
	;---------------------------------------------------------------------------------------
   	msg "sub user_17"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_18 ; Tool Wear Detection
    GOSUB TOOL_MEASURE_WEAR
ENDSUB
;***************************************************************************************
Sub user_19 ; Spindle Warmup 
	GOSUB SPINDLE_WARMUP
ENDSUB
;***************************************************************************************
Sub user_20 ;3D EdgeFinder Probing
	GOSUB PROBE_3D
ENDSUB
;---------------------------------------------------------------------------------------

;***************************************************************************************
; Handwheel Macros
;***************************************************************************************
SUB xhc_probe_z ; Probe Z height
	;---------------------------------------------------------------------------------------
	#3505 = 1	; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
	gosub Z_PROBE ; Probe Z height
ENDSUB
;***************************************************************************************
SUB xhc_macro_9 ;Tool Length Measurement
	;---------------------------------------------------------------------------------------
	msg"Tool Length Measurement"
	gosub TOOL_MEASURE ;Tool Length Measurement
ENDSUB
;---------------------------------------------------------------------------------------

;***************************************************************************************
; Homing Macros
;***************************************************************************************
sub home_all ; HOMING
    gosub home_z
    gosub home_y
    gosub home_x
    ; G53 G01 X0 Y0 Z0 F2000     ; Rapid move to MCS XYZ 0
    G53 G01 Z#4633 F2000		; Move Z axis to HOME position
    G53 G01 X#4631 Y#4632 F2000	; Move X and Y to HOME position
    msg"Homing complete"	
    ;homeIsEstop on             ;  Uncomment if reference switch is acting as E-Stop  
    #3501 = 0					; Reset FLAG [Tool not yet measured]
    #3504 = 0					; Reset FLAG [Initiated Break Check] (0=no, 1=yes)
    m30
ENDSUB

;***************************************************************************************
Sub home_z ; HOMING
    msg "Homing Z Axis"
    M80
    g4p0.2
    home z
ENDSUB

;***************************************************************************************
Sub home_x ; HOMING
    msg "Homing X Axis"
    M80
    g4p0.2
    home x
    ;homeTandem X
ENDSUB

;***************************************************************************************
Sub home_y ; HOMING
    msg "Homing Y Axis"
    M80
    g4p0.2
    home y  ;set Y home position
    ;homeTandem Y
ENDSUB
;---------------------------------------------------------------------------------------

;***************************************************************************************
; Compensation Macros
;***************************************************************************************
Sub zero_set_rotation
	;---------------------------------------------------------------------------------------
    msg "Move to first point  press control-G to continue"
	m0
	#5020 = #5071 ;x1
	#5021 = #5072 ;y1
    msg "Move to second point  press control-G to continue"
	m0
	#5022 = #5071 ;x2
	#5023 = #5072 ;y2
	#5024 = ATAN[#5023 - #5021]/[#5022 - #5020]
	IF [#5024 > 45]
       #5024 = [#5024 - 90] ;points are in Y direction
	ENDIF
	g68 R#5024
	msg "G68 R"#5024" applied, now zero XYZ normally"
	msg "Remove probe IF used"
ENDSUB

;***************************************************************************************
sub zhcmgrid ; Surface Probing
    ;probe scanning routine for eneven surface milling
	;---------------------------------------------------------------------------------------

	;scanning starts at WCS x=0, y=0
	IF [#4100 == 0]
		#4100 = 10  ;number x points
		#4101 = 5   ;number y points
		#4102 = 40  ;max z height
		#4103 = 10  ;min z height
		#4104 = 10.0 ;grid point distance (mm)
		#4105 = 100 ;probing feed
	ENDIF    

	#110 = 0    ;Actual nx
	#111 = 0    ;Actual ny
	#112 = 0    ;Missed measurements counter
	#113 = 0    ;Number of points added
	#114 = 1    ;0: odd x row, 1: even xrow
	;Dialog
	dlgmsg "Surface Grid Probing" "number of x points" 4100 "number of y points" 4101 "max (clearance) Z height" 4102 "min Z height" 4103 "grid point distance" 4104 "Feed" 4105 
   
	IF [#5398 == 1] ; user pressed OK
    	;Move to startpoint
    	G0 z[#4102];to upper Z
    	G0 X0 Y0 ;to start point
    	ZHCINIT [#4104] [#4100] [#4101] ;ZHCINIT gridSize nx ny
    	#111 = 0    ;Actual ny value
    	WHILE [#111 < #4101]
        	IF [#114 == 1]
          		;even x row, go from 0 to nx
          		#110 = 0 ;start nx
          		WHILE [#110 < #4100]
            		;Go up, goto xy, measure
            		G0 z[#4102];to upper Z
            		G0 x[#110 * #4104] y[#111 * #4104] ;to new scan point
            		G38.2 F[#4105] z[#4103];probe down until touch   
            		;Add point to internal table IF probe has touched
            		IF [#5067 == 1]
            			ZHCADDPOINT
            			msg "nx="[#110 +1]" ny="[#111+1]" added"
            			#113 = [#113+1]
            		ELSE
            			;ZHCADDPOINT
             			msg "nx="[#110 +1]" ny="[#111+1]" not added"
              			#112 = [#112+1]
            		ENDIF
            		#110 = [#110 + 1] ;next nx
          		ENDWHILE
          		#114=0
        	ELSE
          		;odd x row, go from nx to 0
          		#110 = [#4100 - 1] ;start nx
          		WHILE [#110 > -1]
            		;Go up, goto xy, measure
            		G0 z[#4102];to upper Z
            		G0 x[#110 * #4104] y[#111 * #4104] ;to new scan point
            		g38.2 F[#4105] z[#4103];probe down until touch  
            		;Add point to internal table IF probe has touched
            		IF [#5067 == 1]
            			ZHCADDPOINT
            			msg "nx="[#110 +1]" ny="[#111+1]" added"
            			#113 = [#113+1]
            		ELSE
              			;ZHCADDPOINT
              			msg "nx="[#110 +1]" ny="[#111+1]" not added"
              			#112 = [#112+1]
            		ENDIF
            		#110 = [#110 - 1] ;next nx
          		ENDWHILE
          		#114=1
        	ENDIF
      		#111 = [#111 + 1] ;next ny
    	ENDWHILE
    	G0 z[#4102];to upper Z
    	ZHCS zHeightCompTable.txt ;Save measured table
    	msg "Done, "#113" points added, "#112" not added" 
  	ELSE
    	;user pressed cancel in dialog
    	msg "Operation canceled"
  	ENDIF
ENDSUB
;---------------------------------------------------------------------------------------

;***************************************************************************************
; Machine Macros
;***************************************************************************************
sub SENSOR_CHECK ; Check Tool Length Sensor Status before measurement
	IF [#4400 == 0]	; [Tool Length Sensor-Type] is 0 (0= Normally Open)
	     #185 = 1	; set error-status (1= open)
	ELSE			; [Tool Length Sensor-Type] is 1 (0= Normally Closed)
	    #185 = 0	; set error-status (0= closed)
	ENDIF
	IF [#5068 == #185]	; Sensor status = error status (0=closed, 1=open)
		dlgmsg "Verify tool sensor is functional"
		IF [#5398 == 1]	; OK-button
		    IF [#5068 == #185]	; Sensor status = error status (0=closed, 1=open)
				errmsg "Tool sensor error, Verify and try again."
		    ENDIF
		ELSE
		    errmsg "Operation canceled"
		ENDIF	
	ENDIF
ENDSUB

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

;***************************************************************************************
Sub TOOL_CHANGE_DLG  ; Call Tool Change Sequence
	;---------------------------------------------------------------------------------------
    Dlgmsg "Which Tool should be changed" " New Tool Number:" 5011
    IF [#5398 == 1] ;OK
		IF [#5011 > 99] 
		    Dlgmsg "Tool Number Incorrect: Please choose Tool Number 1..99"
		    #5011 = #5008				; [New Tool Number] reset to [current tool number]
		ELSE
	    	#3510 = 1					; set FLAG Tool Change initiated from GUI (1= initiated from GUI)
	    	gosub TOOL_CHANGE
		    #3510 = 0					; Reset FLAG Tool Change initiated from GUI
		ENDIF
    ENDIF
ENDSUB

;***************************************************************************************
sub TOOL_CHANGE ; TOOL CHANGE SEQUENCE
	;---------------------------------------------------------------------------------------
    #5015 = 0	; set FLAG: Tool Change not yet executed
    M5 M9	; Spindle off, cooling off
    IF [#5397 == 0]	; Simulator Mode off (0= off)

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
							gosub TOOL_CHANGE
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

;***************************************************************************************
Sub TOOL_NBR_UPDATE  ; Update Tool Number
	;---------------------------------------------------------------------------------------
    #5011 = [#5008]
    Dlgmsg "!!! Tool Update !!!" "Current Tool Number" 5008" New Tool Number" 5011
    IF [#5011 > 99] 
		Dlgmsg "Tool Number Incorrect: Please enter Tool Number 1-99"
		#5011 = #5008					; New Tool Number reset to original
		M30
    ELSE
		#5015 = 1					; Was tool successfully updated 1=Yes
		IF [[#5011] > 0] 
		    M6 T[#5011]
		    ;G43
		ELSE
		    M6 T[#5011]
		ENDIF
    ENDIF
ENDSUB

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

;***************************************************************************************
Sub MOVE_MCS0 ; Move to MCS 0 (Home)
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to MCS 0?"
	IF [#5398 == 1] ;OK
	   	G53 G0 Z0
	    G53 X0 Y0
	ENDIF
ENDSUB

;***************************************************************************************
Sub MOVE_WCS0_G54 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G54 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	G53 G0 Z0
	    G54 X0 Y0
		G54 Z5
	ENDIF
ENDSUB

;***************************************************************************************
Sub MOVE_WCS0_G55 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G55 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	G53 G0 Z0
	    G55 X0 Y0
		G55 Z5
	ENDIF
ENDSUB

;***************************************************************************************
Sub MOVE_WCS0_G56 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G56 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	G53 G0 Z0
	    G56 X0 Y0
		G56 Z5
	ENDIF
ENDSUB

;***************************************************************************************
Sub MOVE_WCS0_G57 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G57 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	G53 G0 Z0
	    G57 X0 Y0
		G57 Z5
	ENDIF
ENDSUB

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

;***************************************************************************************
Sub PROBE_3D ;3D EdgeFinder Probing
	;---------------------------------------------------------------------------------------
	;   #4550 3D-finder 0 point probing direction
	;   #4551 3D-finder 0 point offset X+
	;   #4552 3D-finder 0 point offset X-
	;   #4553 3D-finder 0 point offset Y+
	;   #4554 3D-finder 0 point offset Y-
	Dlgmsg "Set corner edge probing direction: 1=X+ / 2=X- / 3=Y+  / 4=Y-" "Direction:" 4550 
	IF [#4550 == 0]
	ENDIF

	;---- X-Plus-----------------------------------------------------------------------------------
	IF [#4550 == 1]
	    G91 G38.2 x20 F[#4504]
    	G90
    	IF [#5067 == 1]					; When Sensor is triggered
       	    G91 G38.2 x-10 F[#4505]
        	G90
        		IF [#5067 == 1]				; When Sensor is triggered
        			G92 X#4551
        			G91 G00 x-1
        			G90
		        ENDIF
    	ELSE
	    	DlgMsg "ERROR: No Sensor triggered - Measurement failed"
    	ENDIF 
	    #4550 = 0
	ENDIF
	;---- X-Minus-----------------------------------------------------------------------------------
	IF [#4550 == 2]
		G91 G38.2 x-20 F[#4504]
		G90
		IF [#5067 == 1]					; When Sensor is triggered
	    	G91 G38.2 x10 F[#4505]
			G90
			IF [#5067 == 1]				; When Sensor is triggered
				G92 X#4552
				G91 G00 x1 
				G90
			ENDIF
		ELSE
			DlgMsg "ERROR: No Sensor triggered - Measurement failed"
		ENDIF 
	    #4550 = 0
	ENDIF
	;---- Y-Plus-----------------------------------------------------------------------------------
	IF [#4550 == 3]
	    G91 G38.2 y20 F[#4504]
    	G90
		IF [#5067 == 1]					; When Sensor is triggered
		    G91 G38.2 y-10 F[#4505]
			G90
			IF [#5067 == 1]				; When Sensor is triggered
				G92 y#4553
				G91 G00 y-1 
				G90
			ENDIF
		ELSE
			DlgMsg "ERROR: No Sensor triggered - Measurement failed"
		ENDIF 
    	#4550 = 0
	ENDIF 
	;---- Y-Minus-----------------------------------------------------------------------------------
	IF [#4550 == 4]
    	G91 G38.2 y-20 F[#4504]
    	G90
    	IF [#5067 == 1]					; When Sensor is triggered
    	    G91 G38.2 y10 F[#4505]
    		G90
    		IF [#5067 == 1]				; When Sensor is triggered
    			G92 y#4554
    			G91 G00 y1 
    			G90
    		ENDIF
    	ELSE
    		DlgMsg "ERROR: No Sensor triggered - Measurement failed"
    	ENDIF 
    	#4550 = 0
	ENDIF
ENDSUB
;---------------------------------------------------------------------------------------

;***************************************************************************************
; Configuration Macros
;***************************************************************************************
sub config
	;---------------------------------------------------------------------------------------
	GoSub CFG_TOOLCHANGEPOS
	GoSub CFG_ZPROBE
	GoSub CFG_TOOLMEASUREPOS
	;GoSub CFG_3DPROBE
	;GoSub CFG_SPINDLEWARM
ENDSUB

;***************************************************************************************
sub CFG_TOOLCHANGEPOS
	;---------------------------------------------------------------------------------------
	;0= Do nothing, 1 = Move to WCS0, 2= Move to WCS0 + Measure
	Dlgmsg "Tool Change Type" "0,1,2" 4520  
	IF [#5398 == 1] ;OK
		IF [#4520 > 0 ] 
			Dlgmsg "Tool Change Position" "X-Axis Position" 4521 "Y-Axis Position" 4522 "Z-Axis Position" 4523
		ENDIF
	ENDIF
ENDSUB

;***************************************************************************************
sub CFG_ZPROBE
	;---------------------------------------------------------------------------------------
	Dlgmsg "Z probe type" "TYPE 0=Open, 1=Closed" 4400 "Sensor Height" 4510 "Approach feedrate:" 4512 "Probe feedrate:" 4513
ENDSUB

;***************************************************************************************
sub CFG_TOOLMEASUREPOS
	;---------------------------------------------------------------------------------------
	Dlgmsg "Position after Homing Sequence (MCS)" "Position after Homing X (MCS):" 4631 "Position after Homing Y (MCS):" 4632 "Position after Homing Z (MCS):" 4633
	Dlgmsg "Tool Length Sensor position (MCS)" "X-Axis Position (MCS)" 4507 "Y-Axis Position (MCS)" 4508 "Z-Axis Position (MCS)" 4506 "Spindle without Tool" 4509 "Max. Tool Length" 4503 "Fast Probe feedrate:" 4504 "Probe feedrate:" 4505
	Dlgmsg "Position after Tool Measurement" "Position 0-4" 4519 "X-Axis (MCS)" 4524 "Y-Axis (MCS)" 4525 
	Dlgmsg "Tool Wear/Breakage Control" "Enable wear/breakage control" 4529 "Tolerance +/- in mm:" 4528  

	;#4519 What to do after Tool Length Measurement: 
	;0= pre defined point
	;1= WCS 0
	;2= Tool Change Position
	;3= MCS 0
	;4= Remain in place
	;#4524 Position X after Tool Length Measurement   
	;#4525 Position Y after Tool Length Measurement
	;#4526 Position Z after Tool Length Measurement
ENDSUB

;***************************************************************************************
sub CFG_3DPROBE
	;---------------------------------------------------------------------------------------
	;   #4551 set 0 point offset X+
	;   #4552 set 0 point offset X-
	;   #4553 set 0 point offset Y+
	;   #4554 set 0 point offset Y-
	Dlgmsg "3D Finder Probe Offsets" "in direction X+" 4551 "in direction X-" 4552 "in direction Y+" 4553 "in direction Y-" 4554 
ENDSUB

;***************************************************************************************
sub CFG_SPINDLEWARM
	;---------------------------------------------------------------------------------------
	;   #4532 RPM Step 1 for Spindle Warmup
	;   #4533 Runtime Step 1 for Spindle Warmup
	;   #4534 RPM Step 2 for Spindle Warmup
	;   #4535 Runtime Step 2 for Spindle Warmup
	;   #4536 RPM Step 3 for Spindle Warmup
	;   #4537 Runtime Step 3 for Spindle Warmup
	;   #4538 RPM Step 4 for Spindle Warmup
	;   #4539 Runtime Step 4 for Spindle Warmup
	Dlgmsg "Spindle warmup settings" "RPM Step 1" 4532 "Runtime (sec.) Step 1" 4533 "RPM Step 2" 4534 "Runtime(sec.) Step 2" 4535 "RPM Step 3" 4536 "Runtime (sec.) Step 3" 4537 "RPM Step 4" 4538 "Runtime(sec.) Step 4" 4539
ENDSUB

; Available Operations:
;***************************************************************************************
;SUB
;	IF
;		WHILE
;		ENDWHILE
;	ELSE
;	ENDIF
;ENDSUB

;#define AND              &&
;#define IS               ==
;#define ISNT             !=
;#define MAX(x, y)        ((x) > (y) ? (x) : (y))
;#define NOT              !
;#define OR               ||
;#define SET_TO           =




