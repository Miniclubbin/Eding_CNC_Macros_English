;***************************************************************************************
;2023JUL_V7.2
;EDING CNC
;Based on SOROTEC MACRO CNC V2.1e.1 Without ATC
;Derived from SOROTEC
;Translated by MiniClubbin
;***************************************************************************************
;CHANGELOG
;Formatted spacing to enable folding in VSCode
;Renamed subroutines for easier user button assignment
;Split user macros into user_macro.cnc file for subroutine mapping
;Split sensor_check into separate subroutine
;Optimized sub Z_PROBE to return to probing location after tool measurement
;Optimized sub tool_measure return-position logic
;Optimized sub config to match new naming convention
;Optimized sub config to skip unused subroutines
;Optimized sub TOOL_MEASURE_WEAR to include cancel and return-position logic 
;Added sub TOOL_SENSOR_CALIBRATE to calibrate spindle chuck height before use in tool length measurement
;Added sub Z_PROBE_VCARVE to set Z0 .1mm above workpiece
;Added several movement subroutines to call positional moves to various frequented locations for use as handwheel macros
;Added M30 to some subroutines for cancelation logic
;Added terminal message for routine tracking/debugging
;Added ELSE logic for dialog cancel
;Added FLAG #68 to track workpiece rotation compensation active
;Added workpiece rotation reset to homing sequence
;Replaced several error messages with normal terminal messages to speed up workflow
;Updated probing operations to include a rapid retract and slow probe to account for mechanical tool sensors
;Configured sub_config and sub_spindlewarm for spindle warmup on Teknomotor 1.1kW spindle
;Edited Sub TOOL_SENSOR_CALIBRATE to temporarily avoid movement to TCP
;Edited variables to allow for differing probe height values for Z probe and TLO probe
;Added sub probe_cutout and associated variables to automatically set Z0 based on GCODE material thickness and spoilboard surface to avoid manual measurement and protect spoilboard surface
;Added Tool Change Area Guard on/off and ZHCM on/off commands to all tool measurement subs
;Edited sub zhcmgrid to allow specification of Y grid size
;Added warning for sub zero_set_rotation that XY0 must be lower left
;Edited tool measurement macros to protect against crashing tools into sensors after incorrect length estimates
;Removed unnecessary msg commands
;***************************************************************************************

;Variables used

;ZHCM Grid Variables
	;	#4100 ;number x points
	;	#4101 ;number y points
	;	#4102 ;max z height
	;	#4103 ;min z height
	;	#4104 ;X grid point distance (mm)
	;	#4105 ;Y grid point distance (mm)
	;   #4106 ;probing feed
	;	Scan parameters
	;	#110  ;Actual nx
	;	#111  ;Actual ny
	;	#112  ;Missed measurements counter
	;	#113  ;Number of points added
	;	#114  ;0: odd x row, 1: even xrow
; Various
	;	#68 FLAG workpiece rotation compensation active (resets on powerdown)
	;	#185  - TEMP-Variable (Sensor error-status)
	;   #3500 FLAG Initialized
	;   #3501 FLAG Tool measure sequence completedd? 1=YES (resets on powerdown)
	;   #3502 FLAG Only needed for calculation
	;   #3503 FLAG Yes / No in Dialog
	;   #3504 FLAG whether Break Check called by automatic 1=automatic
	;   #3505 FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
	;   #3510 FLAG Tool Change initiated from GUI (1= initiated from GUI)
; Parameter for Type of Tool Length Sensor
	;   #4400 Probe Type (0= NOpen, 1= NClosed)
	;   #4500 TLO Probe Height
; Parameter for Tool Length Measurement
	;   #4501 Current Tool Length
	;   #4502 Old Tool Length
	;   #4503 Maximum Tool Length
	;   #4504 TOOL Fast probing feed (mm/min)
	;   #4505 TOOL Slow probing feed for exact measurement (mm/min)
	;   #4506 Safe Z Height in Machine
	;   #4507 Position for the X Axis
	;   #4508 Position for the Y Axis							 
	;   #4509 MCS Z position of empty spindle chuck at tool probe trigger point (must be negative)
; Parameter for Z-0 point Measurement
	; #4000 - material thickness
	; #4001 - baseplate zero after probing
	; #4002 - measured spoilboard height
	; #4003 - expected spoilboard height from baseplate
	; #4004 - material thickness as programmed in GCODE
	;   #4510 Z Probe sensor activation height (MM)
	;   #4511 Clearance Height
	;   #4512 Z0 Fast feed for probing (mm/min)
	;   #4513 Z0 Slow probing feed for exact measurement (mm/min)
; Parameter for Tool Length Measurement
	;   #4514 Mark Return point for X Pos
	;   #4515 Mark Return point for Y Pos
	;   #4516 Mark Return point for Z Pos
	;   #4517 FLAG (No tool chosen)
	;   #4518 FLAG: Move back to operation starting point (1=YES, 0=NO)
	;   #4519 What to do after Tool Length Measurement: 
	;		0= move to predefined point 
	;		1= move to Work 0 
	;		2= move to Tool Change Position 
	;		3= move to Machine 0 
	;		4= Remain in place
	;   #4520 Tool Change Type 
	;		0= Ignore 
	;		1= Only move WPos 
	;		2= Move WPos + Measure 
	;   #4521 (TYP 0) Tool Change Position  X 
	;   #4522 (TYP 0) Tool Change Position  Y
	;   #4523 (TYP 0) Tool Change Position  Z
	;   #4524 Position X after Tool Length Measurement   
	;   #4525 Position Y after Tool Length Measurement
	;   #4526 Position Z after Tool Length Measurement
	;UNUSED #4527 Distance between spindle chuck and top of tool sensor at Machine Z0 (must be negative)
	;   #4528 Allowable Tolerance for Tool Wear Control
	;   #4529 FLAG whether Automatic Tool Wear Control is enabled
	;UNUSED #4530 FLAG whether Cone Check is enabled
	;UNUSED #4531 Cone height above sensor
; Parameter for Spindle-Warmup
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
	;   #4544 3D-finder Sensor-Type (0= Open, 1= Closed)
	;   #4545 3D-finder probe length (Tool Length)
	;   #4546 3D-finder Tip radius
	;   #4547 3D-finder Radius-Offset
	;   #4548 3D-finder Feed to locate probe (mm/min)
	;   #4549 3D-finder Slow probing feed for exact measurement (mm/min)
; Parameter for Workpiece probe (SOROTEC)
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
	;   #4631 Position in X after the Homing Sequence
	;   #4632 Position in Y after the Homing Sequence
	;   #4633 Position in Z after the Homing Sequence
; SYSTEM VARIABLES
	;   #5001 Current X Pos (Work)
	;   #5002 Current Y Pos (Work)
	;   #5003 Current Z Pos (Work)
	;   #5004 Current A Pos (Work)
	;   #5005 Current B Pos (Work)
	;   #5006 Current C Pos (Work)
	;   #5008 Current Tool Number
	;   #5010 Current Tool Length
	;   #5011 New Tool Number
	;	#5013 G43 Z offset
	;	#5014 G43 X offset
; TOOL CHANGE VARIABLES
	;   #5015 Tool Change-Process (0= Change not executed, 1= Change was executed)
	;   #5016 =  Current Tool Number
	;   #5017 =  Maximum Tool Length
	;   #5019 =  Tool Length Sensor Position X-Axis
	;   #5020 =  Tool Length Sensor Position Y-Axis
	;   #5021 =  Measured tool length
; SYSTEM VARIABLES
	;   #5053 Sensor-Activation point Z Pos (Machine) stored when sensor input triggered
	;   #5061 Sensor-Activation point X Pos (Work)
	;   #5062 Sensor-Activation point Y Pos (Work)
	;   #5063 Sensor-Activation point Z Pos (Work)
	;   #5064 Sensor-Activation point A Pos (Work)
	;   #5065 Sensor-Activation point B Pos (Work)
	;   #5066 Sensor-Activation point C Pos (Work)
	;   #5067 Sensor Impulse:  1 = probe is triggered after G38.2, 0 otherwise
	;   #5068 Sensor Status: 0 = closed, 1 = open (When sensor is set as NO-normal open)
	;   #5071 Current X Pos (Machine)
	;   #5072 Current Y Pos (Machine)
	;   #5073 Current Z Pos (Machine)
	;   #5074 Current A Pos (Machine)
	;   #5075 Current B Pos (Machine)
	;   #5076 Current C Pos (Machine)
	;   #5113 Machine Collision Area Positive Limit Z (Machine)
	;   #5380 Simulation Mode [0=Normal Mode,  1=Yes Simulation Mode]
	;   #5397 RENDER mode [0=normal mode] [1=RENDER mode]
	;   #5398 DlgMsg Return-Value [1=OK, -1=CANCEL]
	;   #5399 Return-Value for functions M55 and M56
; REFERENCE VARIABLES
	;	#5151 Z Height Compensation Status (1=on, 0=off)
	;	#5152 Spindle status (1=on, 0=off)
	;	#5161 G28 X position
	;	#5162 G28 Y position
	;	#5163 G28 Z position
	;	#5181 G30 X position
	;	#5182 G30 Y position
	;	#5183 G30 Z position
	;	#5220 Active Work Coordinate System (G54-59.3)

;***************************************************************************************
(INITIALIZE)
	IF [#3500 == 0]  ; IF [Initialize] is 0  proceed
		#3500 = 1			;set FLAG [initialized]
		IF [#4504 == 0]   	
			#4504 =50	; set [Tool Fast probing feed] (mm/min)
		ENDIF
		IF [#4505 == 0]   	
			   #4505 =20  	; set [Tool Slow probing feed] for exact measurement (mm/min)  
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
		msg "intialized"
	ENDIF

;***************************************************************************************
; Homing Macros
;***************************************************************************************
sub home_all ; HOMING
	gosub home_z
    gosub home_y
    gosub home_x
    G53 G01 Z#4633 F2000		; Move Z axis to HOME position
    G53 G01 X#4631 Y#4632 F2000	; Move X and Y to HOME position
    msg"Homing complete"	
    ;homeIsEstop on             ;  Uncomment if reference switch is acting as E-Stop  
    #3501 = 0					; Reset FLAG [Tool not yet measured]
    #3504 = 0					; Reset FLAG [Initiated Break Check] (0=no, 1=yes)
	
	; WORKPIECE ROTATION RESET
	IF [#68 == 1] ; if workpiece rotation compensation active
		dlgmsg "Reset G68 rotation offset?"
		IF [#5398 == 1] ; user pressed OK
			G69 ; cancel workpiece rotation compensation
			#68 = 0 ; reset FLAG workpiece rotation compensation active
			msg "workpiece rotation compensation reset"
		ENDIF
	ENDIF
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

;***************************************************************************************
; Compensation Macros
;***************************************************************************************
Sub zero_set_rotation
    msg "Ensure XY 0 is lower left corner, all measurements must be positive"
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
	   msg "rotated 90deg"
	ENDIF
	g68 R#5024
	#68 = 1 ; set FLAG workpiece rotation compensation active
	msg "G68 R"#5024" applied, now zero XYZ normally"
	msg "Remove probe IF used"
ENDSUB
;***************************************************************************************
;***************************************************************************************
sub zhcmgrid ; Surface Probing routine for eneven surface milling
    ;#5151 is current ZHC status (1 = ON, 0 = OFF)
    ; 'ZHCINITEX' is used for different grid sizes across X and Y

	;scanning starts at Work x=0, y=0 and moves positive
	IF [#4100 == 0]
		#4100 = 10  ;number x points
		#4101 = 5   ;number y points
		#4102 = 40  ;max z height
		#4103 = 10  ;min z height
		#4104 = 10.0 ;X grid point distance (mm)
		#4105 = 10.0 ;Y grid point distance (mm)
        #4106 = 100 ;probing feed
	ENDIF    
    ;reset scan parameters
	#110 = 0    ;Actual nx
	#111 = 0    ;Actual ny
	#112 = 0    ;Missed measurements counter
	#113 = 0    ;Number of points added
	#114 = 1    ;0: odd x row, 1: even xrow
	;Dialog
	dlgmsg "Surface Grid Probing" "Number of X points" 4100 "Number of Y points" 4101 "Clearance Z height (WCS)" 4102 "Z Probing (Absolut WCS)" 4103 "X Grid Size" 4104 "Y Grid Size" 4105 "Probe Feedrate" 4106
   
	IF [#5398 == 1] ; user pressed OK
    	;Move to startpoint
		G53 G0 z[#4506]
		G90 ;absolute mode
    	G0 X0 Y0 ;to start point
		G0 z[#4102];to Z clearance height
    	;ZHCINITEX <grid sizeX> <grid sizeY> <n of points in X> <n of points in Y>
        ZHCINITEX [#4104] [#4105] [#4100] [#4101] ;define gridSize nx ny
    	#111 = 0    ;current ny value
    	WHILE [#111 < #4101] ;current Y counter is less than Y points
        	IF [#114 == 1] ; row is even
          		#110 = 0 ;reset counter
          		WHILE [#110 < #4100]
            		;Go up, goto xy, measure
            		G0 z[#4102];to upper Z
            		G0 x[#110 * #4104] y[#111 * #4105] ;to new scan point
            		G38.2 F[#4106] z[#4103];probe down until touch   
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
            		G0 x[#110 * #4104] y[#111 * #4105] ;to new scan point
            		g38.2 F[#4106] z[#4103];probe down until touch  
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
    	;G0 z[#4102];to upper Z
		G53 G0 z[#4506] ;Go to Safe Z
		G0 X0 Y0 ;to start point
    	ZHCS zHeightCompTable.txt ;Save measured table
    	msg "Done, "#113" points added, "#112" not added" 
  	ELSE
    	;user pressed cancel in dialog
    	msg "Operation canceled"
  	ENDIF
ENDSUB

;***************************************************************************************
; Machine Macros
;***************************************************************************************
sub SENSOR_CHECK ; Check Tool Length Sensor Status before measurement
	IF [#4400 == 0]	; [Tool Length Sensor-Type] is 0 (0= Normally Open)
	     #185 = 1	; set error-status (1= open)
	ELSE		; [Tool Length Sensor-Type] is 1 (0= Normally Closed)
	    #185 = 0	; set error-status (0= closed)
	ENDIF
	; checking tool sensor status"
	IF [#5068 == #185]	; Sensor status = error status (0=closed, 1=open)
		dlgmsg "Verify tool sensor is functional"
		IF [#5398 == 1]	; OK-button
		    IF [#5068 == #185]	; Sensor status = error status (0=closed, 1=open)
				errmsg "Tool sensor error, verify and try again."
			ELSE
				msg "tool sensor OK"
		    ENDIF
		ELSE
		    msg "Operation canceled"
			
		ENDIF	
	ELSE
		msg "tool sensor OK"
	ENDIF
ENDSUB
;***************************************************************************************

Sub Z_PROBE ; Probe for Work Z-zero height
	; #185  - TEMP-Variable (Sensor error-status)

	;--------------------------------------------------
	;3DFinder - Cancel Measurement
	;--------------------------------------------------
	;*********UNCOMMENT IF USING 3D PROBE*************
	;
	IF [#5008 > 97]		; Tool 98 and 99 are 3D-button - no Tool Length Measurement
		msg "Tool is 3D-button -> Tool Length Measurement not executed"
		M30			; END of sequence
	ENDIF

	IF [[#3501 == 1] or [#4520 < 2] or [#3505 == 1]]	; [Tool already Measured] or [Tool Change Mode] is 0 or 1 or [called from handwheel]
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------
		#4518 = 0 				; FLAG: Move back to operation starting point (1=YES, 0=NO)
		IF [#3505 == 0] 			; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
			DlgMsg "Measure Work Z 0" 
		ELSE
			msg "Called from Handwheel"
			#5398 = 1
		ENDIF	
		#3505 = 0				; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
		IF [[#5398 == 1] AND [#5397 == 0]]	; OK button pressed and RENDER Mode off !!
			M5	; Spindle shutdown
			msg "Probing Z height"	
			G38.2 G91 z-50 F[#4512] 	; Probe towards sensor until change in signal at probe feedrate
			IF [#5067 == 1]			; IF sensor point activated
			    G91 G0 Z2              ; back off trigger point 
				G38.2 G91 z-5 F[#4513]	; Slowly probe down until sensor activates
			    G90				; absolute position mode
	 		    IF [#5067 == 1]		; IF sensor point activated
					G0 Z#5063	; Rapid move to sensor activation point
					; setting Z offset"
					G92 Z[#4510] 	; Overwrite current Z height with probe height
					G0 Z[#4510 + 15] ; Rapid retract to 5mm above probe height
					msg"Z-0 probe complete"
			    ELSE
					G90 
					errmsg "ERROR: Sensor not activated"
			    ENDIF
			ELSE	; retry
			    G90 
			    DlgMsg "WARNING: No Sensor triggered! Try again?" 
			    IF [#5398 == 1] ;OK 
					GOSUB Z_PROBE
			    ELSE
				errmsg "Measurement failed!"
			    ENDIF
			ENDIF
		ELSE
			msg "z_probe canceled"
		ENDIF   	
	ELSE
		#3505 = 0	; reset FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
		DlgMsg "Hit OK to measure tool first" 
		IF [#5398 == 1] 		;OK pressed
	   		#4514 = #5071		; set Return point for X Pos to current Machine position
			#4515 = #5072		; set Return point for Y Pos to current Machine position
			#4516 = #5073		; set Return point for Z Pos to current Machine position
			#4518 = 1		; FLAG: set Move back to operation starting point (1=YES, 0=NO)
			msg "tool_measure called from Z_probe"
			GoSub TOOL_MEASURE
			msg "tool measured, returning to Z_probe"
			gosub Z_PROBE
		ELSE
			msg "z_probe canceled"
		ENDIF
	ENDIF
ENDSUB
;***************************************************************************************
Sub Z_PROBE_VCARVE ; Probe for Work Z-zero height

	;--------------------------------------------------
	;3DFinder - Cancel Measurement
	;--------------------------------------------------
	;*********UNCOMMENT IF USING 3D PROBE*************
	;
	IF [#5008 > 97]		; Tool 98 and 99 are 3D-button - no Tool Length Measurement
		msg "Tool is 3D-button -> Tool Length Measurement not executed"
		M30			; END of sequence
	ENDIF

	; #185  - TEMP-Variable (Sensor error-status)
	IF [[#3501 == 1] or [#4520 < 2]]	; [Tool already Measured] or [Tool Change Mode] is 0 or 1
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------
		#4518 = 0 		; set FLAG: Move back to operation starting point (1=YES, 0=NO)
		IF [#3505 == 0] 	; Tool Length Measurement not called from handwheel (1=Handwheel)
;***VARIANCE****************************************************************************
			DlgMsg "Offset actual Z0 for VCarve tolerance" ; Generate dialog to confirm on screen
;***VARIANCE****************************************************************************
		ENDIF	
		#3505 = 0	; reset FLAG Tool Length Measurement called from handwheel (1=Handwheel)
		IF [[#5398 == 1] AND [#5397 == 0]]	; [OK button] pressed and [RENDER Mode] off
			M5	; Spindle shutdown
			msg "Probing Z height"	
			G38.2 G91 z-50 F[#4512] 	; Lower Z 50mm at [fast probe feed] until sensor triggered and stop
			IF [#5067 == 1]			; sensor triggered, value recorded to [#5063]
			    G91 G0 Z2              ; back off trigger point 
				G38.2 G91 z-5 F[#4513]	; Slowly probe down until sensor activates
			    G90				; absolute position mode
	 		    IF [#5067 == 1]		; sensor triggered, value recorded to [#5063]
					G0 Z[#5063]	; Rapid Z move to [recorded trigger point]
;***VARIANCE****************************************************************************
					msg "setting vcarve Z offset"
					G92 Z[#4510+.1] ; ***Offset Z by sensor height #4510 + .1mm for VCarve tolerance***
;***VARIANCE****************************************************************************
					G0 Z[#4510 + 15] ; Rapid retract to 5mm above [sensor height]
					msg"Z-0 probe complete"
				ELSE
					G90 
					errmsg "ERROR: Sensor not activated"
				ENDIF
			ELSE	;retry
			    G90 
			    DlgMsg "WARNING: No Sensor triggered! Try again?" 
			    IF [#5398 == 1] ; [OK button] pressed 
					GOSUB Z_PROBE_VCARVE
			    ELSE
					errmsg "Measurement failed!"
			    ENDIF
			ENDIF
		ELSE
			msg "z_probe canceled"
		ENDIF   	
	ELSE
		#3505 = 0 ; reset FLAG Tool Length Measurement called from handwheel (1=Handwheel)
		DlgMsg "Hit OK to measure tool first" 
		IF [#5398 == 1] 	; [OK button] pressed
	   		#4514 = #5071	; set Return point for X Pos to current Machine position
			#4515 = #5072	; set Return point for Y Pos to current Machine position
			#4516 = #5073	; set Return point for Z Pos to current Machine position
			#4518 = 1	; set FLAG: Move back to operation starting point (1=YES, 0=NO)
			msg "tool_measure called from Z_probe"
			GoSub TOOL_MEASURE
			msg "tool measured, returning to Z_probe"
			gosub Z_PROBE_VCARVE
		ELSE
			msg "z_probe canceled"
		ENDIF
	ENDIF
ENDSUB
;***************************************************************************************
Sub TOOL_MEASURE ; Tool Length Measurement
	;--------------------------------------------------
	;3DFinder - Cancel Tool Length Measurement
	;--------------------------------------------------
	;*********UNCOMMENT IF USING 3D PROBE*************
	;
	IF [#5008 > 97]		; Tool 98 and 99 are 3D-button - no Tool Length Measurement
		msg "Tool is 3D-button -> Tool Length Measurement not executed"
		M30			; END of sequence
	ENDIF
	
	msg "Tool Measurement initiated"
	; #4500 TLO probe sensor height
	; #4509 Distance between spindle chuck and top of tool sensor at Machine Z0 (must be negative)
	; #4510 Z probe sensor height
	#5016 = [#5008]	; Current Tool Number
	#5017 = [#4503]	; Maximum Tool Length
	#5019 = [#4507]	; set variable to Tool Length Sensor X-Axis Position
	#5020 = [#4508]	; set variable to Tool Length Sensor Y-Axis Position
	#5021 = 0 	; Measured tool length variable



	; Sensor Status check -----------------------------
	GOSUB SENSOR_CHECK
	;--------------------------------------------------

    ; start Tool Length Measurement"
    dlgmsg "How long is the new tool" "Est. Tool Length:" 5017 ; Enter estimated tool length
    
	; confirm sequence and check entered values for errors
	IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off

		; --- COMMENT BELOW IF YOU WANT INDIVIDUAL FAILURE MESSAGES ---
		; if either of these conditions fail
        IF [ [#5017 <= 0] OR [ [#4509 + #5017 + 10] > [#4506] ] ] ;Value is negative OR sensor height + tool + 10 is longer than z safe height 
            dlgmsg "Length must be between 0 and MAX, ok to restart"
            IF [#5398 == 1] ;OK pressed
				msg "restarting measurement"
				gosub tool_measure
			ELSE
				msg "Tool Measurement aborted"
				M30 ; cancel sequence
		    ENDIF
		ENDIF		
		; --- COMMENT ABOVE IF YOU WANT INDIVIDUAL FAILURE MESSAGES ---

		; --- UNCOMMENT BELOW IF YOU WANT INDIVIDUAL FAILURE MESSAGES ---
		; test estimated length is positive
		;IF [[#5017] <= 0] ; test whether Tool Length negative
		;   DlgMsg "ERROR: Tool length must be positive" "Est. Tool Length:" 5017
        ;    IF [#5398 == 1] ;OK pressed
		;		gosub tool_measure
		;	ELSE
		;		errmsg "Tool length must be positive, Tool Change aborted" ; will require reset
		;		msg "Tool length must be positive, Tool Change aborted" ; NO required reset
		;		M30 ; cancel sequence
		;    ENDIF
        ;ENDIF
		; test estimated length is not too long
        ;IF [[#4509 + #5017 + 10] > [#4506]] ; test whether measured value higher than safe height
		;    DlgMsg "ERROR: Tool too long" "Est. Tool Length:" 5017
        ;    IF [#5398 == 1] ;OK pressed
		;		gosub tool_measure
		;	ELSE ;choose your message type and comment/uncomment
		;		errmsg "Tool too long, Tool Change aborted" ; will require reset
		;		msg "Tool too long, Tool Change aborted" ; NO required reset
		;		M30 ; cancel sequence
		;    ENDIF
        ;ENDIF
		; --- UNCOMMENT ABOVE IF YOU WANT INDIVIDUAL FAILURE MESSAGES ---

		TCAGuard off ;allow machine into tool change area as defined in TCA setup
    	;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    	#5019 = #5051
    	if [#5019 == 1]
        	ZHC off
    	endif

		; move to tool sensor position"
		M9 ; turn off coolant
		M5 ; turn off spindle
		G53 G0 z[#4506]			; Move to Z Safe Height [Machine] 
		G53 G0 x[#5019] y[#5020]		; Move to Tool Length Sensor Position
		G53 G0 z[#4509 + #5017 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [estimated Tool Length] + 30 = MCS Z distance
		G91 G1 Z-20 F800 	; slow Z minus 20
		G90
		; measure tool length, save results, apply Z-offset if second tool
		; probing"
		G53 G38.2 Z[#4509] F[#4504]	; Probe Z to sensor height with Probe Feed #4504
		IF [#5067 == 1]	; Sensor is triggered
			G91 G0 Z2              ; back off trigger point 
			G91 G38.2 Z-5 F[#4505]	; Probe Z at [slow Probe feed] until trigger activates
			G90				; Mode for absolute coordinates
			; calculate tool length or throw error
			IF [#5067 == 1]				; Sensor is triggered
				#5021 = [#5053 - #4509]	; Recorded tool length = sensor point - chuck height
				G53 G0 z[#4506]	; Z Safe Height [Machine]
				msg "Tool Length = " #5021
				; calculate Z offset for next tool or use new measurement for first tool
				IF [#3501 == 1] 		; Tool measure sequence completedd? 1=YES
					; applying Z offset"
					#4502 = [#4501]		; save current tool length
					#4501 = [#5021]		; save new tool length
					#3502 = [#4501 - #4502]	; Record tool length difference (offset)
					G92 Z[#5003 - #3502]	; set Z-0 offset [Current Z Work]-[measured difference]
					msg "Z Offset: " [#5003 - #3502]
				; first tool, record length
				ELSE
					msg "new tool length saved"
					#4501 = [#5021]		; Save new Tool Length measurement value
				ENDIF
				; Move back to Z0 probe position if flagged (ex. from z probe sequence)
				IF [#4518 == 1] ; FLAG: Move back to operation starting point (1=YES, 0=NO)
					msg "returning to previous position"
					G53 G0 Z#4506 ; Z Safe Height [Machine]
					G53 G0 X#4514 Y#4515 ; Move to previous XY position
					G53 G1 Z#4516 F1000
					#4518 = 0			; FLAG: Move back to starting point (1=YES, 0=NO)
					#3501 = 1			; FLAG: Tool measure sequence completed? (1=YES, 0=NO)
				; move to configured option
				ELSE
					G90 
					IF [#4519 == 0] ; move to: 0= pre defined point
						msg "moving to predefined position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X#4524 Y#4525 ; move to configured point 
					ENDIF
					IF [#4519 == 1] ; move to: 1= Work 0 
						msg "moving to wcs 0"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G0 X0 Y0 ; Work 0
					ENDIF	
					IF [#4519 == 2] ; move to: 2= Tool Change Position
						msg "moving to tool change position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X#4521 Y#4522 ; Tool Change Position XY
						G53 G0 Z#4523 ; Tool Change Position Z
					ENDIF
					IF [#4519 == 3] ; move to: 3= Machine 0
						msg "moving to home position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X0 Y0 ; Machine 0
					ENDIF
					IF [#4519 == 4] ; move to: 4= remain in place
						msg "moving to safe Z"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
					ENDIF
				ENDIF
				; reset flags
				#4518 = 0	; reset FLAG: Move back to operation starting point (1=YES, 0=NO)
				#3501 = 1	; set FLAG: Tool measure sequence completed? (1=YES, 0=NO)
			ELSE
				errmsg "ERROR: No Sensor triggered - CONFIRM RESET"
			ENDIF
		ELSE
			errmsg "ERROR: No Sensor triggered - Measurement failed"
		ENDIF
	ELSE
		msg "Tool Change aborted"
	ENDIF

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
    ;Check if ZHeight comp was on before and switch ON again if it was.
    IF [#5019 == 1]
        ZHC on
    ENDIF

ENDSUB
;***************************************************************************************
sub change_tool ; TOOL CHANGE SEQUENCE
	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    #5019 = #5051
    if [#5019 == 1]
        ZHC off
    endif

	msg "Tool Change initiated"
    #5015 = 0	; set FLAG: Tool Change not yet executed
    M9 ; turn off coolant
	M5 ; turn off spindle
    IF [#5397 == 0]	; RENDER Mode off (0= off)

		; 0 = Ignore Toolchange
		IF [[#4520] == 0] 			; Tool Change Type  0= Ignore, 1 = Return to WCS 0, 2= Measure and return to WCS 0 
			#5015 = 1				; set FLAG tool changed 1=Yes
			msg "tool change type 0 ignored"
		ENDIF
	
		; 1 = Return to WCS 0
		IF [[#4520] == 1] 				; Tool Change Type  0= Ignore, 1 = Return to WCS 0, 2= Measure and return to WCS 0 
			#3503 = 1				; Is Tool already inserted?  1=Yes
			;tool change type 1"
			IF [[#5011] == [#5008]]  ;IF new tool matches Current Tool
				Dlgmsg "Tool is already inserted. Measure tool?"
				IF [#5398 == 1] ;OK pressed
					#3503 = 1
				ELSE
					#3503 = 0
					msg "skipped measuring current tool"
				ENDIF
			ENDIF
			IF [#3503 == 1] 			; Is Tool already inserted?  1=Yes
				msg "moving to tool change position"
				G53 G0 Z[#4523]			; Safe Height
				G53 G0 X[#4521] Y[#4522]	; Tool Change Position X Y
				Dlgmsg "Please change tool" "Current Tool:" 5008 "New Tool:" 5011
				IF [#5398 == 1] ;OK pressed
					IF [#5011 > 99] 
						Dlgmsg "Tool Number Incorrect: Please enter Tool Number 1-99"
						IF [#5398 == 1] ;OK pressed
							msg "restarting sequence"
							gosub change_tool
						ELSE
							errmsg "Tool Change failed"
						ENDIF
					ELSE
						#5015 = 1	; Tool Change executed 1=Yes
					ENDIF
				ELSE
					msg "Tool Change canceled"
				ENDIF
			ENDIF
		ENDIF		

		; 2= Measure and return to WCS 0 
		IF [[#4520] == 2] ; Tool Change Type  0= Ignore, 1 = Return to WCS 0, 2= Measure and return to WCS 0 
			;tool change type 2"
			#3503 = 1 ; Tool Number already inserted  1=Yes
			IF [[#5011] == [#5008]] ;IF new tool matches Current Tool
				Dlgmsg "Tool is already inserted. Measure tool?"
				IF [#5398 == 1] ;OK
					#3503 = 1
				ELSE
					#3503 = 0
					msg "skipped measuring current tool"
				ENDIF
			ENDIF
			IF [#3503 == 1] 
				IF [[#5008 > 0] AND [#5008 < 98] AND [#4529 == 1]]	; Current Tool Number between 0 -97 and Break Check activated
					#3504 = 1			; FLAG whether Break Check from automatic initiated was 1=automatic
					msg "break check called from tool_change"
					GOSUB TOOL_MEASURE_WEAR		; Break Check called
					#3504 = 0			; FLAG whether Break Check from automatic initiated was 1=automatic
				ELSE
					;msg "Break Check skipped"
				ENDIF
				msg "move to tool change position"
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
					msg "tool changed, proceed to measurement"
					#5015 = 1			; Tool Change executed 1=Yes
				ELSE
				   	msg "Tool Change canceled" 
				ENDIF
			ENDIF
		ENDIF
		
		; Measure Tool
		IF [[#5015] == 1]    ; Tool Change-Process 1= Change was executed
			M6 T[#5011]				; New Tool Number set
			msg "Tool " #5008" changed to Tool " #5011 " "
			IF [#4520 == 2] 		; Tool Change Type  0= Ignore, 1 = Return to WCS 0, 2= Measure and return to WCS 0 
			    msg "tool_measure called from tool_change"
				gosub TOOL_MEASURE		; Tool Length Measurement called  [WARNING - Must occur after M6 T.. command is called]
			ENDIF
			#5015 = 0			; Tool Change executed 1=Yes
		ENDIF
    ENDIF ; SIMULATOR Mode

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
    ;Check if ZHeight comp was on before and switch ON again if it was.
    IF [#5019 == 1]
        ZHC on
    ENDIF

ENDSUB
;***************************************************************************************
Sub TOOL_CHANGE_DLG  ; Call Tool Change Sequence

    Dlgmsg "Which Tool should be changed" " New Tool Number:" 5011
    IF [#5398 == 1] ;OK
		IF [#5011 > 99] 
		    Dlgmsg "Tool Number Incorrect: only 1-99"
		    #5011 = #5008				; [New Tool Number] reset to [current tool number]
			M30
		ELSE
	    	#3510 = 1					; set FLAG Tool Change initiated from GUI (1= initiated from GUI)
	    	msg "change_tool called from dlg"
			gosub change_tool
		    #3510 = 0					; Reset FLAG Tool Change initiated from GUI
		ENDIF
    ENDIF
ENDSUB
;***************************************************************************************
Sub TOOL_NBR_UPDATE  ; Update Tool Number
    #5011 = [#5008]
    Dlgmsg "!!! Tool Update !!!" "Current Tool Number" 5008" New Tool Number" 5011
    IF [#5011 > 99] 
		Dlgmsg "Tool Number Incorrect: only 1-99"
		#5011 = #5008				; [New Tool Number] reset to [current tool number]
		M30
    ELSE
		#5015 = 1				; Was tool successfully updated 1=Yes
		IF [[#5011] > 0] 
		    M6 T[#5011]
			msg "Tool # updated to T" #5011 " "
		ENDIF
    ENDIF
ENDSUB

;***************************************************************************************
Sub TOOL_SENSOR_CALIBRATE
    ; Sensor Status check -----------------------------
    GOSUB SENSOR_CHECK
    ;--------------------------------------------------
  	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    #5019 = #5051
    if [#5019 == 1]
        ZHC off
    endif
	
	; Turn off spindle and coolant
	M9 ; turn off coolant
	M5 ; turn off spindle
	GOSUB TCP
    dlgmsg "Remove tool and nut from spindle"
	

    IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off
		
		GOSUB TMP

		G91 G0 X-8
		G90 G53 G0 Z[#5103 + 40]    ; Rapid Z to 20mm above sensor [Lowest Z + 40]
		
		msg "Calibrating Chuck Height in Machine"
        G38.2 G91 z-50 F[#4512] ; Fast Probe, stop when triggered
        IF [#5067 == 1]			; IF sensor point triggered
            G91 G0 Z2              ; back off trigger point 
            G38.2 G91 z-5 F[#4505]   ; slow probe, stop when triggered
            G90                 ; Absolute mode
            G53 G0 Z[#5053]	    ; Rapid move to Machine activation point
            msg "saving chuck height"
			#4509=#5053         ; Record value as chuck height variable #4509
            G53 G0 z[#4506]     ; Return to safe Z
            msg "Completed measurement, Chuck height="[#4509]
        ELSE
			DlgMsg "WARNING: No Sensor triggered! Try again?" 
	        IF [#5398 == 1] ;OK 
			    GOSub TOOL_SENSOR_CALIBRATE
		    ELSE
                G90 
				errmsg "ERROR: Sensor not activated"
			ENDIF
        ENDIF
    ELSE
        G90
		msg "Tool sensor calibration canceled"      
	ENDIF

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
    ;Check if ZHeight comp was on before and switch ON again if it was.
    IF [#5019 == 1]
        ZHC on
    ENDIF

endSub

;***************************************************************************************
; MOVEMENTS
;***************************************************************************************
Sub MOVE_Machine0 ; Move to Machine 0 (Home)
	MSG "MOVE TO MACHINE HOME"
	G90
	G53 G0 Z0
	G53 G0 X0 Y0
ENDSUB
;***************************************************************************************
Sub MOVE_WCS0_G54 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G54 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	msg "move to G54 XY 0 and lower Z"
		G90
		G53 G0 Z0
	    G54 G0 X0 Y0
		G54 G1 Z10 F1000
		G54 G1 Z5 F500
	ENDIF
ENDSUB
;***************************************************************************************
Sub MOVE_WCS0_G55 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G55 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	msg "move to G55 XY 0 and lower Z"
		G90
		G53 G0 Z0
	    G55 G0 X0 Y0
		G55 G1 Z10 F1000
		G55 G1 Z5 F500
	ENDIF
ENDSUB
;***************************************************************************************
Sub MOVE_WCS0_G56 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G56 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	msg "move to G56 XY 0 and lower Z"
		G90
		G53 G0 Z0
	    G56 G0 X0 Y0
		G56 G1 Z10 F1000
		G56 G1 Z5 F500
	ENDIF
ENDSUB
;***************************************************************************************
Sub MOVE_WCS0_G57 ; Move to WCS XY0 Z5
	;---------------------------------------------------------------------------------------
  	DlgMsg "Should machine move to G57 XY 0 and lower Z?"
	IF [#5398 == 1] ;OK
	   	msg "move to G57 XY 0 and lower Z"
		G90
		G53 G0 Z0
	    G57 G0 X0 Y0
		G57 G1 Z10 F1000
		G57 G1 Z5 F500
	ENDIF
ENDSUB
;***************************************************************************************
Sub RAISE_Z ; Z Safe
   	msg "Move to Z Safe"
	G90
	G53 G0 Z#4506
ENDSUB
;***************************************************************************************
Sub WCS_0 ; Move to WCS 0 Safe Z
   	msg "Move to WCS 0 Safe Z"
	G90
	G53 G0 Z#4506
	G0 X0 Y0
ENDSUB
;***************************************************************************************
Sub WCS0_Z5 ; Move to WCS 0 Z5
   	msg "Move to WCS 0 Z5"
	G90
	IF [[#5001 == 0] AND [#5002 == 0]] ; if XY = 0
		IF [[#5003] > 10] ; curent work Z height is more than 10
			G1 Z10 F1000 ; move to Z10 at feed 1000
		ENDIF
	ELSE ; if XY not 0
		msg "moving to safe Z"
		G53 G0 Z#4506 ; Move to safe Z
		msg "moving to XY0"
		G0 X0 Y0 ; move to XY0
		G1 Z10 F1000 ; Lower Z to 10 at feed 1000
	ENDIF
	G1 Z5 F500 ; Lower Z to 5 at feed 500
ENDSUB
;***************************************************************************************
Sub LOWER_Z ; Move Z to 1
   	; TODO: if XY pos outside tool sensor collision area, then continue otherwise cancel
	msg "Move Z to 1"
	G90
	IF [[#5003] > 10] ; curent work Z height is more than 10
		G1 Z10 F1000 ; move to Z10 at feed 1000
	ENDIF
	G1 Z1 F500 ; move to Z1 at feed 500
ENDSUB
;***************************************************************************************

Sub TCP ; Move to Tool Change Position
   	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    #5019 = #5051
    if [#5019 == 1]
        ZHC off
    endif
	
	msg "Move to Tool Change Position"
	M9 ; turn off coolant
	M5 ; turn off spindle
	G90
	G53 G0 Z#4506
	G53 G0 X[#4521] Y[#4522]

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
    ;Check if ZHeight comp was on before and switch ON again if it was.
    IF [#5019 == 1]
        ZHC on
    ENDIF

ENDSUB

Sub TMP ;Move to Tool Measurement Position

	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    #5019 = #5051
    if [#5019 == 1]
        ZHC off
    endif

   	msg "Move to Tool Measure Position"
	M9 ; turn off coolant
	M5 ; turn off spindle
	G90
	G53 G0 Z#4506
	G53 G0 X[#4507] Y[#4508]

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
    ;Check if ZHeight comp was on before and switch ON again if it was.
    IF [#5019 == 1]
        ZHC on
    ENDIF

ENDSUB

Sub PROBE_CUTOUT
	; #4000 - material thickness
	; #4001 - baseplate zero after probing
	; #4002 - measured spoilboard height
	; #4003 - expected spoilboard height from baseplate
	; #4004 - material thickness as programmed in GCODE
	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    #5019 = #5051
    if [#5019 == 1]
        ZHC off
    endif

	M9 ; turn off coolant
	M5 ; turn off spindle	
	GOSUB SENSOR_CHECK
   	MSG "CURRENT SPOILBOARD HEIGHT: " [#4002]
	dlgmsg "set cutout z0 height" "Spoilboard Thickness" 4002 "Material thickness" 4004 "Est. Tool Length:" 5017
    
	IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off
     	IF [ [#5017 <= 0] OR [ [#4509 + #5017 + 10] > [#4506] ] ] ;Value is negative OR tool too long for sensor height
            dlgmsg "Length must be between 0 and MAX, ok to restart"
            IF [#5398 == 1] ;OK pressed
				msg "restarting measurement"
				gosub PROBE_CUTOUT
			ELSE
				msg "Cutout probing FAILED"
				M30 ; cancel sequence
		    ENDIF
		ENDIF
		; Saving current position"
		#4514 = #5071		; set Return point for X Pos to current Machine position
		#4515 = #5072		; set Return point for Y Pos to current Machine position		
		; move to tool sensor position"
		G90
		G53 G0 Z[#4506] ; Move to Z Safe
		G53 G0 X[#4507] Y[#4508] ; Move to Tool Length Sensor Position
		G53 G0 z[#4509 + #5017 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [estimated Tool Length] + 30 = MCS Z distance
		G91 G1 Z-20 F800 	; slow Z minus 20
		G90
		msg "Probing Table Z height"	
		G53 G38.2 Z[#4509] F[#4504]	; Probe Z to sensor height with Probe Feed #4504
		IF [#5067 == 1]			; IF sensor point activated
		    G91 G0 Z2              ; back off trigger point 
			G91 G38.2 Z-5 F[#4505]	; Probe Z at [slow Probe feed] until trigger activates
		    G90				; absolute position mode
		    IF [#5067 == 1]		; IF sensor point activated
				G0 Z#5063	; Rapid move to sensor activation point
				; setting spoilboard Z offset + material thickness
				G92 Z[#4500 - #4002 - #4004] 	; Overwrite current Z height with probe height - Spoilboard height - material height
				msg "Z Offset: " [#4500 - #4002 - #4004]
				G53 G0 Z#4506 ; Rapid retract to safe height
				; returning to previous position"
				G53 G0 Z#4506 ; Z Safe Height [Machine]
				G53 G0 X#4514 Y#4515 ; Move to previous XY position
		    ELSE
				G90 
				msg "ERROR: Sensor not activated"
		    ENDIF
		ELSE	; retry
			    G90 
			    DlgMsg "WARNING: No Sensor triggered! Try again?" 
			    IF [#5398 == 1] ;OK 
					GOSUB PROBE_CUTOUT
			    ELSE
				errmsg "Measurement failed!"
			    ENDIF
			ENDIF
	ELSE
		msg "Cutout probing aborted"
	ENDIF

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup

ENDSUB

Sub PROBE_CUTOUT_AUTO ;called from GCODE to cut out piece
	; #4000 - material thickness
	; #4001 - baseplate zero after probing
	; #4002 - measured spoilboard height
	; #4003 - expected spoilboard height from baseplate
	; #4004 - material thickness as programmed in GCODE
	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5019, #5051 indicates that ZHeight comp is on    
    #5019 = #5051
    if [#5019 == 1]
        ZHC off
    endif
	
	M9 ; turn off coolant
	M5 ; turn off spindle	
	GOSUB SENSOR_CHECK
   	MSG "CURRENT SPOILBOARD HEIGHT #4002: " [#4002] " MATERIAL HEIGHT: " #4004
    #5398=1
	IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off
     	IF [ [#5017 <= 0] OR [ [#4509 + #5017 + 10] > [#4506] ] ] ;Value is negative OR tool too long for sensor height
            dlgmsg "Length must be between 0 and MAX, ok to restart"
            IF [#5398 == 1] ;OK pressed
				msg "restarting measurement"
				gosub PROBE_CUTOUT_AUTO
			ELSE
				msg "Cutout probing FAILED"
				M30 ; cancel sequence
		    ENDIF
		ENDIF
		; Saving current position"
		#4514 = #5071		; set Return point for X Pos to current Machine position
		#4515 = #5072		; set Return point for Y Pos to current Machine position		
		; move to tool sensor position"
		G90
		G53 G0 Z[#4506] ; Move to Z Safe
		G53 G0 X[#4507] Y[#4508] ; Move to Tool Length Sensor Position
		G53 G0 z[#4509 + #5017 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [estimated Tool Length] + 30 = MCS Z distance
		G91 G1 Z-20 F800 	; slow Z minus 20
		G90
		msg "Probing Table Z height"	
		G53 G38.2 Z[#4509] F[#4504]	; Probe Z to sensor height with Probe Feed #4504
		IF [#5067 == 1]			; IF sensor point activated
		    G91 G0 Z2              ; back off trigger point 
			G91 G38.2 Z-5 F[#4505]	; Probe Z at [slow Probe feed] until trigger activates
		    G90				; absolute position mode
		    IF [#5067 == 1]		; IF sensor point activated
				G0 Z#5063	; Rapid move to sensor activation point
				; setting spoilboard Z offset + material thickness
				G92 Z[#4500 - #4002 - #4004] 	; Overwrite current Z height with probe height - Spoilboard height - material height
				msg "Z Offset: " [#4500 - #4002 - #4004]
				G53 G0 Z#4506 ; Rapid retract to safe height
				; returning to previous position"
				G53 G0 Z#4506 ; Z Safe Height [Machine]
				G53 G0 X#4514 Y#4515 ; Move to previous XY position
		    ELSE
				G90 
				msg "ERROR: Sensor not activated"
		    ENDIF
		ELSE	; retry
			    G90 
			    DlgMsg "WARNING: No Sensor triggered! Try again?" 
			    IF [#5398 == 1] ;OK 
					GOSUB PROBE_CUTOUT
			    ELSE
				errmsg "Measurement failed!"
			    ENDIF
			ENDIF
	ELSE
		msg "Cutout probing aborted"
	ENDIF

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup

ENDSUB

;***************************************************************************************
; Configuration Macros
;***************************************************************************************
sub config
	GoSub CFG_TOOLCHANGEPOS
	gosub CFG_TLOPROBE
	GoSub CFG_ZPROBE
	GoSub CFG_TOOLMEASUREPOS
	GoSub CFG_SPINDLEWARM
	GOSUB CFG_SPOILBOARD
	;GoSub CFG_3DPROBE
ENDSUB
;***************************************************************************************
sub CFG_TOOLCHANGEPOS
	;0= Ignore, 1 = Return to WCS 0, 2= Measure and return to WCS 0
	Dlgmsg "Tool Change Type" "0,1,2" 4520  
	IF [#5398 == 1] ;OK
		IF [#4520 > 0 ] 
			Dlgmsg "Tool Change Position" "X-Axis Position" 4521 "Y-Axis Position" 4522 "Z-Axis Position" 4523
		ENDIF
	ENDIF
ENDSUB
;***************************************************************************************
sub CFG_ZPROBE
	Dlgmsg "Z probe type" "TYPE 0=Open, 1=Closed" 4400 "Sensor Height" 4510 "Approach feedrate:" 4512 "Probe feedrate:" 4513
ENDSUB

	;   #4504 TOOL Fast probing feed (mm/min)
	;   #4505 TOOL Slow probing feed for exact measurement (mm/min)
sub CFG_TLOPROBE
	Dlgmsg "TLO probe" "TYPE 0=Open, 1=Closed" 4400 "Sensor Height" 4500 "Approach feedrate:" 4504 "Probe feedrate:" 4505
ENDSUB
;***************************************************************************************
sub CFG_TOOLMEASUREPOS
	Dlgmsg "Position after Homing Sequence (MCS)" "Position after Homing X (MCS):" 4631 "Position after Homing Y (MCS):" 4632 "Position after Homing Z (MCS):" 4633
	Dlgmsg "Tool Length Sensor position (MCS)" "X-Axis Position (MCS)" 4507 "Y-Axis Position (MCS)" 4508 "Safe Z-Axis Position (MCS)" 4506 "Spindle without Tool" 4509 "Max. Tool Length" 4503 "Fast Probe feedrate:" 4504 "Probe feedrate:" 4505
	Dlgmsg "Position after Tool Measurement" "Position 0-4" 4519 "X-Axis (MCS)" 4524 "Y-Axis (MCS)" 4525 
	Dlgmsg "Tool Wear/Breakage Control" "Enable wear/breakage control" 4529 "Tolerance +/- in mm:" 4528  
	;#4519 What to do after Tool Length Measurement: 
	;0= pre defined point
	;1= Work 0
	;2= Tool Change Position
	;3= Machine 0
	;4= Remain in place
	;#4524 Position X after Tool Length Measurement   
	;#4525 Position Y after Tool Length Measurement
	;#4526 Position Z after Tool Length Measurement
ENDSUB

SUB CFG_SPOILBOARD
	Dlgmsg "Spoilboard Height" "spoilboard thickness: " 4002
ENDSUB
;***************************************************************************************
;sub CFG_3DPROBE
	;   #4551 set 0 point offset X+
	;   #4552 set 0 point offset X-
	;   #4553 set 0 point offset Y+
	;   #4554 set 0 point offset Y-
;	Dlgmsg "3D Finder Probe Offsets" "in direction X+" 4551 "in direction X-" 4552 "in direction Y+" 4553 "in direction Y-" 4554 
;ENDSUB
;***************************************************************************************
sub CFG_SPINDLEWARM
	;   #4532 RPM Step 1 for Spindle Warmup
	;   #4533 Runtime Step 1 for Spindle Warmup
	;   #4534 RPM Step 2 for Spindle Warmup
	;   #4535 Runtime Step 2 for Spindle Warmup
	;   #4536 RPM Step 3 for Spindle Warmup
	;   #4537 Runtime Step 3 for Spindle Warmup
	;   #4538 RPM Step 4 for Spindle Warmup
	;   #4539 Runtime Step 4 for Spindle Warmup
	; Dlgmsg "Spindle warmup settings" "RPM Step 1" 4532 "Runtime (sec.) Step 1" 4533 "RPM Step 2" 4534 "Runtime(sec.) Step 2" 4535 "RPM Step 3" 4536 "Runtime (sec.) Step 3" 4537 "RPM Step 4" 4538 "Runtime(sec.) Step 4" 4539
	Dlgmsg "Spindle warmup settings" "RPM Step 1" 4532 "Runtime (sec.) Step 1" 4533
ENDSUB


;***************************************************************************************
; UNUSED
;***************************************************************************************
Sub TOOL_MEASURE_WEAR ; Tool Wear Detection
	;---------------------------------------------------------------------------------------
	; #185  - TEMP-Variable (Sensor error-status)
	; #4509 Distance between spindle chuck and top of tool sensor at Machine Z0 (must be negative)     	(Tool Length Measurement)
	; #5021 =  Measured tool length
	; #4529 = 0
	; IF [#4529 == 1]	; #4529 FLAG whether Automatic Tool Wear is enabled

	IF [#3501 == 1]		; Tool measure sequence completedd? 1=YES
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------

		msg "Tool Wear Detection"
		;move to tool length sensor position
		msg "move to tool sensor position"
		M9 ; turn off coolant
		M5 ; turn off spindle
		G53 G0 z[#4506]			; Move to Z Safe Height [Machine] 
		G53 G0 x[#5019] y[#5020]		; Move to Tool Length Sensor Position
		G53 G0 z[#4509 + #5017 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [estimated Tool Length] + 30 = MCS Z distance
		G91 G1 Z-20 F800 	; slow Z minus 20
		G90
		msg "probing"
		G53 G38.2 Z[#4509] F[#4504]	; Probe Z to sensor height with Probe Feed #4504 
		IF [#5067 == 1]	; Sensor is triggered
			G91 G0 Z2              ; back off trigger point 
            G38.2 G91 z-5 F[#4505]   ; slow probe, stop when triggered
			G90	; Mode for absolute coordinates
			; calculate tool length or throw error
			IF [#5067 == 1]	; Sensor is triggered
				#4501 = [#5053 - #4509]	; record actual Tool Length = probe point  - chuck height
				G53 G0 z[#4506]	; Z Safe Height [Machine]
				msg "measured Length = " #4501
				; compare current length to configured tolerance
				IF [[[#5021 + #4528] > [#4501]]  and [[#5021 - #4528] < [#4501]]]
					msg "tool wear OK"
					msg "dimensional deviation:" [#5021 - #4501]	
					
				ELSE ; tool wear outside configured tolerance
					msg "tool wear out of tolerance"
					#3504 = 0 ; reset FLAG break check called automatically 1=automatic
					G53 G0 z[#4506]	; Move to Z Safe Height [Machine] 
					G53 G0 x[#5019] y[#5020] ; Move to Tool Length Sensor Position
					Dlgmsg "Tool worn or broken, continue job?" " dimensional deviation:" 4501	
					IF [#5398 == 1] ;OK
						Dlgmsg "WARNING: Job is continued"	
					ELSE
						#3504 = 0 ; reset FLAG break check called automatically 1=automatic
						errmsg "job aborted. Replace tool and use 'goto' function to restart"
					ENDIF
				ENDIF

				; if measurement was called manually, where to move once complete
				IF [#3504 == 0]	; FLAG whether Break Check from automatic initiated was 1=automatic
				    G90 
					IF [#4519 == 0] ; move to: 0= pre defined point
						msg "moving to predefined position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X#4524 Y#4525 ; move to configured point 
					ENDIF
					IF [#4519 == 1] ; move to: 1= Work 0 
						msg "moving to wcs 0"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G0 X0 Y0 ; Work 0
					ENDIF	
					IF [#4519 == 2] ; move to: 2= Tool Change Position
						msg "moving to tool change position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X#4521 Y#4522 ; Tool Change Position XY
						G53 G0 Z#4523 ; Tool Change Position Z
					ENDIF
					IF [#4519 == 3] ; move to: 3= Machine 0
						msg "moving to home position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X0 Y0 ; Machine 0
					ENDIF
					IF [#4519 == 4] ; move to: 4= remain in place
						msg "moving to safe Z"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
					ENDIF
				; if called from change_tool, return to change_tool
				ENDIF 				
			ELSE
				#3504 = 0	; reset FLAG break check called automatically 1=automatic
				errmsg "ERROR: No Sensor triggered"
			ENDIF
		ELSE
			#3504 = 0	; reset FLAG break check called automatically 1=automatic
			errmsg "ERROR: No Sensor triggered"
		ENDIF
	ELSE
	   DlgMsg "Tool was not Measured"
	ENDIF
	#3504 = 0	; reset FLAG break check called automatically 1=automatic
ENDSUB
;***************************************************************************************
Sub PROBE_3D ;3D EdgeFinder Probing
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
		IF [#5067 == 1]				; When Sensor is triggered
	    	G91 G38.2 x10 F[#4505]
			G90
			IF [#5067 == 1]			; When Sensor is triggered
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
		IF [#5067 == 1]				; When Sensor is triggered
		    G91 G38.2 y-10 F[#4505]
			G90
			IF [#5067 == 1]			; When Sensor is triggered
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
;***************************************************************************************
Sub SPINDLE_WARMUP  ; Spindle Warmup 
	DlgMsg "Start Spindle Warmup?"
	IF [#5398 == 1]	 ;OK
		G53 G00 Z0
		msg "spindle step 1"
		M03 S#4532 	;   #4532 RPM Step 1 for Spindle Warmup
		G04 P#4533	;   #4533 Runtime Step 1 for Spindle Warmup
		;msg "spindle step 2"
		;M03 S#4534  ;   #4534 RPM Step 2 for Spindle Warmup
		;G04 P#4535	;   #4535 Runtime Step 2 for Spindle Warmup
		;msg "spindle step 3"
		;M03 S#4536	;   #4536 RPM Step 3 for Spindle Warmup
		;G04 P#4537	;   #4537 Runtime Step 3 for Spindle Warmup
		;msg "spindle step 4"
		;M03 S#4538	;   #4538 RPM Step 4 for Spindle Warmup
		;G04 P#4539	;   #4539 Runtime Step 4 for Spindle Warmup
		msg "spindle warmup complete"
		M05
	ENDIF
ENDSUB	

;***************************************************************************************
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
