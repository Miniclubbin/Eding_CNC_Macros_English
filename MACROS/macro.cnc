;***************************************************************************************
;2023JUL_V7.2
;EDING CNC
;Based on SOROTEC MACRO CNC V2.1e.1 Without ATC
;Derived from SOROTEC
;Translated by MiniClubbin
;***************************************************************************************


;Variables used

;ZHCM Scanning
	;	Grid Variables
	;	#4100 ;number x points
	;	#4101 ;number y points
	;	#4102 ;max z height
	;	#4103 ;min z height
	;	#4104 ;X grid point distance (mm)
	;	#4105 ;Y grid point distance (mm)
	;   #4106 ;probing feed

	;	Scan parameters
	;	#4107  ;Actual nx
	;	#4108  ;Actual ny
	;	#4109  ;Missed measurements counter
	;	#4110  ;Number of points added
	;	#4111  ;0: odd x row, 1: even xrow
	;   #4112  ;Length X
	;   #4113  ;Length Y
	;   #4114  ;Buffer distance X (from X0)
	;   #4115  ;Buffer distance Y (from Y0)
	;   #4116	;Current X0
	;   #4117	;Current Y0
; Various
	;	#68 FLAG workpiece rotation compensation active (resets on powerdown)
	;	#185  - TEMP-Variable (Sensor error-status)
	;   #3500 FLAG Initialized
	;   #3501 FLAG Tool measure sequence completedd? 1=YES (resets on powerdown)
	;   #3502 FLAG Only needed for calculation
	;   #3503 FLAG whether to proceed with tool change sequence
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

    ;   #5025 = Tool Measure Flag if ZHC was on
    ;   #5026 = Change Tool Flag if ZHC was on
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
    G53 G01 Z#4633 F1000		; Move Z axis to HOME position
    G53 G01 X#4631 Y#4632 F1000	; Move X and Y to HOME position
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
	; ZHC RESET
	IF [#5151 == 1] ; if Z height compensation active
		dlgmsg "Turn off Z Height Compensation?"
		IF [#5398 == 1] ; user pressed OK
			ZHC off ; Turn off ZHC
			G4 P0.5
			;msg "ZHC off commanded by homing"
			#5025 = 0 ; reset FLAG ZHC active
			#5026 = 0 ; reset FLAG ZHC active
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
sub zhcmgrid ; Surface Probing routine for uneven surface milling
    ;#5151 is current ZHC status (1 = ON, 0 = OFF)
    ; 'ZHCINITEX' is used for different grid sizes across X and Y

	;Check that tool is 3D probe
	IF [#5008 < 98]	; 3D probe not inserted
			msg "Canceled: Must use 3D probe for scanning"
			M30
	ENDIF

	;scanning starts at Work x=0, y=0 and moves positive
	IF [#4100 == 0]
		#4112 = 100 ;Length X
		#4113 = 50 ;Length Y
		#4100 = 4  ;number x points
		#4101 = 2   ;number y points
		#4102 = 40  ;max z height
		#4103 = 10  ;min z height
		#4104 = [[#4112]/[[#4100]-1]] ;X grid distance = X length div by npoints minus 1
		#4105 = [[#4113]/[[#4101]-1]] ;Y grid distance = Y length div by npoints minus 1
        #4106 = 100 ;probing feed
		#4114 = 0  ;Buffer distance X (from X0)
		#4115 = 0  ;Buffer distance Y (from Y0)
	ENDIF    
    ;reset scan parameters
	#4107 = 0    ;Actual nx
	#4108 = 0    ;Actual ny
	#4109 = 0    ;Missed measurements counter
	#4110 = 0    ;Number of points added
	#4111 = 1    ;0: odd x row, 1: even xrow
	
	;Dialog
	dlgmsg "Is XYZ0 set to lower left corner?"
	IF [#5398 == 1]	; user pressed OK
		dlgmsg "Surface Grid Probing" "X Length" 4112 "Number of X points (2 or more)" 4100 "Y Length" 4113 "Number of Y points (2 or more)" 4101 "Clearance Z height (WCS)" 4102 "Z Probe depth from 0 (WCS)" 4103 "X clearance distance from 0" 4114 "Y clearance distance from 0" 4115
	   	IF [#5398 == 1]

			;calculate grid size based on length and desired number of points

			;NO BUFFER DISTANCE
			;#4104 = [[#4112]/[[#4100]-1]] ;X grid distance = X length div by npoints minus 1
			;#4105 = [[#4113]/[[#4101]-1]] ;Y grid distance = Y length div by npoints minus 1

			;WITH BUFFER DISTANCE
			#4104 = [[#4112-[2*[#4114]]]/[[#4100]-1]] ;X grid distance = X length - buffer distance div by npoints minus 1
			#4105 = [[#4113-[2*[#4115]]]/[[#4101]-1]] ;Y grid distance = Y length - buffer distance div by npoints minus 1

			msg "X grid size: " #4104 "  Y grid size: " #4105
	    	
			;Save current XY0 for recall later and reset XY0 to buffer distance
			G53 G0 z[#4506] ; Z safe height
			G90 ;absolute mode
	    	G0 X0 Y0 ;to start point
			#4116 = #5071 ;Save Current X Pos (Machine)
			#4117 = #5072 ;Save Current Y Pos (Machine)
			g4p0.2 ; pause .2 seconds
			G0 X[#4114] Y[#4115] ;move to buffer start point
			G10 L20 P[#5220] X0Y0	; Set current WCS offset [#5220] X and Y zero
			g4p0.2 ; pause .2 seconds

			;Probe ZHC
			;Move to startpoint
			G53 G0 z[#4506]
			G90 ;absolute mode
	    	G0 X0 Y0 ;to start point
			G0 z[#4102];to Z clearance height
	    	;ZHCINITEX <grid sizeX> <grid sizeY> <n of points in X> <n of points in Y>
	        ZHCINITEX [#4104] [#4105] [#4100] [#4101] ;define gridSize nx ny
	    	#4108 = 0    ;current ny value
	    	WHILE [#4108 < #4101] ;current Y counter is less than Y points
	        	IF [#4111 == 1] ; row is even
	          		#4107 = 0 ;reset counter
	          		WHILE [#4107 < #4100]
	            		;Go up, goto xy, measure
	            		G0 z[#4102];to upper Z
	            		G0 x[#4107 * #4104] y[#4108 * #4105] ;to new scan point [current n * grid distance]
	            		G38.2 F[#4106] z[#4103];probe down until touch   
	            		;Add point to internal table IF probe has touched
	            		IF [#5067 == 1]
	            			ZHCADDPOINT
	            			msg "nx="[#4107 +1]" ny="[#4108+1]" added"
	            			#4110 = [#4110+1]
	            		ELSE
	            			;ZHCADDPOINT
   		          			msg "nx="[#4107 +1]" ny="[#4108+1]" not added"
    	          			#4109 = [#4109+1]
    	        		ENDIF
    	        		#4107 = [#4107 + 1] ;next nx
    	      		ENDWHILE
    	      		#4111=0
    	    	ELSE
    	      		;odd x row, go from nx to 0
    	      		#4107 = [#4100 - 1] ;start nx
    	      		WHILE [#4107 > -1]
    	        		;Go up, goto xy, measure
    	        		G0 z[#4102];to upper Z
    	        		G0 x[#4107 * #4104] y[#4108 * #4105] ;to new scan point [current n * grid distance]
    	        		g38.2 F[#4106] z[#4103];probe down until touch  
    	        		;Add point to internal table IF probe has touched
    	        		IF [#5067 == 1]
    	        			ZHCADDPOINT
    	        			msg "nx="[#4107 +1]" ny="[#4108+1]" added"
    	        			#4110 = [#4110+1]
    	        		ELSE
    	          			;ZHCADDPOINT
    	          			msg "nx="[#4107 +1]" ny="[#4108+1]" not added"
    	          			#4109 = [#4109+1]
    	        		ENDIF
    	        		#4107 = [#4107 - 1] ;next nx
    	      		ENDWHILE
    	      		#4111=1
    	    	ENDIF
    	  		#4108 = [#4108 + 1] ;next ny
    		ENDWHILE
    		;G0 z[#4102];to upper Z
			G53 G0 z[#4506] ;Go to Safe Z
			G53 G0 X[#4116] Y[#4117] ;move to original XY0
			G10 L20 P[#5220] X0Y0 ; Reset current WCS offset X and Y zero
			G90
    		ZHCS zHeightCompTable.txt ;Save measured table
    		msg "Done, "#4110" points added, "#4109" not added"
			ZHCcheck 20 ;list ZHC statistics
		ELSE				;user pressed cancel in dialog
			msg "Operation canceled"
			m30 ;end sequence
	  	ENDIF
	ELSE
		msg "Canceled: Restart when XYZ 0 is set to lower left corner"
		m30 ;end sequence
	ENDIF
ENDSUB

SUB ZHC_CHECK
	IF [[#5151 == 0] AND [#5397 == 0]]	; ZHC off and RENDER Mode off
		dlgmsg "Turn on ZHC and set Z0?"
		IF [#5398 == 1]	; OK-button
			ZHC on ; Turn on ZHC
			G4 P0.5
			goSub Z_PROBE
			dlgmsg "Remove probe and continue"
			IF [#5398 == -1]	; Cancel-button
				ZHC off
				msg "Canceled job and reset ZHC"
				M30
			ENDIF
		ELSE
			msg "ZHC skipped"
		ENDIF
	ENDIF
ENDSUB


;***************************************************************************************
; Machine Macros
;***************************************************************************************
sub SENSOR_CHECK ; Check Tool Length Sensor Status before measurement
	IF [#4400 == 0]	; [Tool Length Sensor-Type] is 0 (Normally Open)
	     #185 = 1	; set flag error-status (1= error if input closed)
	ELSE		; [Tool Length Sensor-Type] is 1 (Normally Closed)
	    #185 = 0	; set flag error-status (0= error if input open)
	ENDIF
	; checking tool sensor status"
	IF [[#5068 == #185]	AND [#5380 == 0]]; Sensor status = error status and not in simulation mode
		dlgmsg "Verify probe sensors"
		IF [#5398 == 1]	; OK-button
		    IF [#5068 == #185]	; Sensor status = error status (0=closed, 1=open)
				errmsg "Tool sensor error, verify and try again."
			ELSE
				msg "probe sensor OK"
		    ENDIF
		ELSE
		    msg "Operation canceled"
			m30
		ENDIF	
	ELSE
		msg "probe sensor OK"
	ENDIF
ENDSUB
;***************************************************************************************
Sub Z_PROBE ; Probe for Work Z-zero height

	;--------------------------------------------------
	;3DFinder - Cancel Measurement
	;--------------------------------------------------
	;IF [#5008 > 97]		; Tool 98 and 99 are 3D-probe - no Tool Length Measurement
	;	msg "Tool is 3D-probe -> Tool Length Measurement not executed"
	;	M30	; END of sequence and reset job
	;ENDIF

	IF [[#3501 == 1] or [#4520 < 2] or [#3505 == 1] or [#5008 > 97]]	; do not measure tool if: [Tool already Measured] or [Tool Change Mode] is 0 or 1 or [called from handwheel] or [current tool] is 3d probe
		; Sensor Status check -----------------------------
		GOSUB SENSOR_CHECK
		;--------------------------------------------------
		#4518 = 0 				; FLAG: Move back to operation starting point (1=YES, 0=NO)
		IF [#3505 == 0] 			; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
			DlgMsg "Measure Work Z 0" 
		ELSE
			msg "Zprobe called from Handwheel"
			#5398 = 1
		ENDIF	
		#3505 = 0 ; reset FLAG whether Tool Length Measurement called from handwheel 1=Handwheel

		IF [[#5398 == 1] AND [#5397 == 0]]	; OK button pressed and RENDER Mode off !!
			M9 ; turn off coolant
	        M5 ; turn off spindle
			msg "Probing Z height"

			;IF [#5008 == 0] ;current tool is 0
			;	G91 g0 x-8 ;INCREMENTAL MOVE TO ALIGN EMPTY HOLDER
			;	G90
			;ENDIF

			G38.2 G91 z-50 F[#4512] 	; Probe towards sensor at probe feedrate
			IF [#5067 == 1]			; IF sensor point activated
			    G91 G0 Z2              ; back off trigger point 
				G38.2 G91 z-5 F[#4513]	; Slowly probe down until sensor activates
			    G90				; absolute position mode
	 		    IF [#5067 == 1]		; IF sensor point activated
					G0 Z#5063	; Rapid move to sensor activation point
					IF [#5008 > 97]		; Tool 98 and 99 are 3D-probe
						G10 L20 P[#5220] Z0 	; Overwrite current Z height to 0
					ELSE
						G10 L20 P[#5220] Z[#4510] 	; Overwrite current Z height with probe height
					ENDIF
					G53 G0 z[#4506]	; Move to Z Safe Height [Machine] 
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
			M30
		ENDIF   	
	ELSE
		#3505 = 0	; reset FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
		DlgMsg "Hit OK to measure tool first" 
		IF [#5398 == 1] 		;OK pressed
	   		#4514 = #5071		; set Return point for X Pos to current Machine position
			#4515 = #5072		; set Return point for Y Pos to current Machine position
			#4516 = #5073		; set Return point for Z Pos to current Machine position
			#4518 = 1		; FLAG: set Move back to operation starting point (1=YES, 0=NO)
			msg "tool measurement called from Z_probe"
			GoSub TOOL_MEASURE
			msg "tool measured, returning to Z_probe"
			gosub Z_PROBE
		ELSE
			msg "z_probe canceled"
			M30
		ENDIF
	ENDIF
ENDSUB
;***************************************************************************************
sub change_tool ; TOOL CHANGE SEQUENCE

; skip tool change if 70-series tool, proceed to set Z0 for material thickness
IF [[#5011 >= 70] AND [#5011 <= 79]] ;new tool is 70-series auto cutout
		goSub PROBE_CUTOUT_AUTO	
		;M6 T[#5011]				; New Tool Number set
		;msg "Tool " #5008" changed to Tool " #5011
ELSE		
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    
	;Check ZHeight comp and switch off when on, remember the state in #5025 (tool measure) or #5026 (tool change), #5151 indicates that ZHeight comp is on    
    #5026 = #5151 ;set temp flag for ZHC status
    if [#5026 == 1]
        ZHC off
		;msg "ZHC off commanded by tool change"
		G4 P0.5
    endif

	msg "Tool Change initiated: " %d
	msg "Initial Tool Measurement Status: " #3501
    M9 ; turn off coolant
	M5 ; turn off spindle
    #5015 = 0 ; reset FLAG: Tool Change not yet executed

    IF [#5397 == 0]	; RENDER Mode off (0= off)
        ; Tool Change Type  0= Ignore, 1= Skip measurement, 2= Measure		
		
		; 0 = Ignore Toolchange
		IF [[#4520] == 0] 
			msg "tool change type 0 ignored"
		ENDIF

		; Toolchange not ignored (type 1 or 2)
		IF [[#4520] > 0] 
			#3503 = 1 ;set FLAG to proceed with tool change sequence
            
			;IF new tool matches Current Tool
            IF [[#5011] == [#5008]] 
				; measurement logic for tool already inserted
                IF [#4520 == 2] ; Tool change type is measurement
                    #3503 = 0 ;reset FLAG whether to proceed with tool change sequence because tool is already inserted
                    IF [#3501 == 0] ; measurement not yet completed
                        Dlgmsg "Measure tool"
                        IF [#5398 == 1] ;OK pressed
                            gosub TOOL_MEASURE
                        ELSE 
                            msg "skipped measuring current tool"
							#3501 = 0 ;reset measurement flag for safety
                        ENDIF
					ELSE
						msg "tool inserted and measured"
						;#3501 = 0 ;reset measurement flag for safety
                    ENDIF
				ELSE ; Tool change type 1 skips measurement
    				Dlgmsg "Tool is already inserted. Proceed with change sequence?"
    				IF [#5398 == 1] ;OK pressed
    					#3503 = 1 ;set FLAG whether to proceed with tool change sequence
    				ELSE
    					#3503 = 0 ;reset FLAG whether to proceed with tool change sequence
    					msg "skipped tool change sequence"
    				ENDIF
    			ENDIF
			ENDIF

			;Proceed with tool change
            IF [#3503 == 1] ;FLAG whether to proceed with tool change sequence
				; PLACEHOLDER save current position
				;IF [#4519 == 5] ; move to: 5= previous position
				;	#4514 = #5071	; set Return point for X Pos to current Machine position
				;	#4515 = #5072	; set Return point for Y Pos to current Machine position
				;ENDIF

				; move to TCP
                msg "moving to tool change position"
				G53 G0 Z[#4523]	; Safe Height
				G53 G0 X[#4521] Y[#4522] ; Tool Change Position X Y
				
				; Perform tool change
				#5027 = #[5400 + #5011] ; New tool length
				#5028 = #[5500 + #5011] ; New tool diameter
                Dlgmsg "Please change tool" "Current Tool:" 5008 "New Tool:" 5011
				IF [#5398 == 1] ;OK pressed
					#[5400 + #5011] = #5027 ; update Length if manually changed in dialog
					#[5500 + #5011] = #5028 ; update Diameter if manually changed in dialog
					IF [#5011 > 99] ; tool beyond catalog
						Dlgmsg "Tool Number Must be Number 1-99" "New Tool:" 5011
						IF [#5398 == 1] ;OK pressed
							msg "restarting sequence"
							gosub change_tool
						ELSE
							#5015 = 0 ; Tool Change executed 1=Yes
							errmsg "Tool Change failed"
						ENDIF
					ENDIF
					;msg "tool changed"
					#5015 = 1 ; Tool Change executed 1=Yes
				ELSE
				   	msg "Tool Change canceled" 
					#5015 = 0
				ENDIF
			ENDIF
		ENDIF

		; Tool Change-Process was executed
		IF [[#5015] == 1]    
			M6 T[#5011]				; New Tool Number set
			msg "Tool " #5008" changed to Tool " #5011

			; Measure tool
            IF [#4520 == 2] ; Tool change type is measurement 
			    ;msg "tool_measure called from tool_change"
				gosub TOOL_MEASURE	; Tool Length Measurement called  [WARNING - Must occur after M6 T.. command is called]
			ENDIF
			#5015 = 0 ; reset Tool Change executed flag
		ENDIF
    ENDIF 

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
	;msg "TCAGuard on Tool Change"

    ;Check if ZHeight comp was on before and switch ON again if it was.
    if [[#5026 == 1] OR [#5025 == 1]]
        ZHC on
		G4 P0.5
		#5026 = 0
		;msg "ZHC on commanded by Tool Change"
    ENDIF
	S0
	msg "Tool Change completed: " %d
	msg "Final Tool Measurement Status: " #3501
ENDIF

ENDSUB
;***************************************************************************************
Sub TOOL_MEASURE ; Tool Length Measurement

	;--------------------------------------------------
	;3DFinder - Cancel Tool Length Measurement
	IF [#5008 > 97]		; Tool 98 and 99 are 3D-probe - no Tool Length Measurement
		S0
		msg "Tool is 3D-probe -> Tool Length Measurement not executed"
    	M30	; END of sequence and reset job
	ENDIF
	;--------------------------------------------------

	; Sensor Status check -----------------------------
	GOSUB SENSOR_CHECK
	;--------------------------------------------------	

	msg "Tool Measurement initiated"
	; #4500 TLO probe sensor height
	; #4509 Distance between spindle chuck and top of tool sensor at Machine Z0 (must be negative)
	; #4510 Z probe sensor height
	#5016 = [#5008]	; Current Tool Number
	#5017 = [#4503]	; Maximum Tool Length
	#5019 = [#4507]	; set variable to Tool Length Sensor X-Axis Position
	#5020 = [#4508]	; set variable to Tool Length Sensor Y-Axis Position
	#5021 = 0 	; Reset measured tool length variable
	#5027 = #[5400 + #5008] ; current tool length
	#5028 = #[5500 + #5008] ; current tool diameter
	dlgmsg "How long is the new tool" "Recorded Tool Length:" 5027 "Recorded Tool Diameter" 5028
    
	; confirm sequence and check entered values for errors
	IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off
		#[5400 + #5008] = #5027 ; update length if manually changed in dialog
		#[5500 + #5008] = #5028 ; update diameter if manually changed in dialog
		
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

		TCAGuard off ;allow machine into tool change area as defined in TCA setup

    	;Check ZHeight comp and switch off when on, remember the state in #5025 or #5026, #5151 indicates that ZHeight comp is on    
    	#5025 = #5151 ;set temp flag for ZHC status
		G4 P0.5
    	if [#5025 == 1]
        	ZHC off
			G4 P0.5
			;msg "ZHC off commanded by tool measurement"
    	endif

		; move to tool sensor position"
		M9 ; turn off coolant
		M5 ; turn off spindle
		G53 G0 z[#4506]			; Move to Z Safe Height [Machine] 
		G53 G0 x[#5019] y[#5020]		; Move to Tool Length Sensor Position

		IF [#5008 == 0] ;current tool is 0
			G91 g0 x-8 ;INCREMENTAL MOVE TO ALIGN EMPTY HOLDER
			G90
		ENDIF

		G53 G0 z[#4509 + #5027 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [recorded Tool Length] + 30 = MCS Z distance
		G38.2 G91 Z-20 F500 	; slow Z minus 20 with probe active in case of crash
	    IF [[#5067 == 1]	AND [#5380 == 0]] ; if sensor triggered and simulation mode is 0
		    G91 G0 Z5
			G90						; G90 -> Absolute distance mode
			;Check if ZHeight comp was on before and switch ON again if it was.
    		if [[#5026 == 1] OR [#5025 == 1]]
		        ZHC on
				G4 P0.5
				;msg "ZHC on commanded by tool measurement"
  			ENDIF
			TCAGuard on ;disallow machine into tool change area as defined in TCA setup
		    errmsg "Measurement aborted! -> Unexpected sensor trigger"
        ENDIF
        
        G90

		; measure tool length, save results, apply Z-offset if second tool
		G53 G38.2 Z[#4509] F[#4504]	; Probe Z to sensor height with Probe Feed #4504
		IF [#5067 == 1]	; Sensor is triggered
			G91 G0 Z2              ; back off trigger point 
			G91 G38.2 Z-5 F[#4505]	; Probe Z at [slow Probe feed] until trigger activates
			G90				; Mode for absolute coordinates

			; calculate tool length
			IF [#5067 == 1]				; Sensor is triggered
				;Calibrate spindle nose measurement if probing empty toolholder T0
				IF [#5008 == 0] ;current tool is 0
					#4509=#5053 
					MSG "Updated chuck height : "#4509
				ENDIF

				#5021 = [#5053 - #4509]	; Recorded tool length = sensor point - chuck height
				G53 G0 z[#4506]	; Z Safe Height [Machine]
				;msg "Tool Length = " #5021
				;Update tool length in tool table

				#[5400 + #5016] = #5021	;[tool table + current tool number] = measured length
				msg "Tool Length = " #5021" written to table line "#5016
				
                ; calculate Z offset for next tool or use new measurement for first tool
				IF [#3501 == 1] 		; Tool measure sequence completed? 1=YES
					; applying Z offset"
					#4502 = [#4501]		; save current tool length
					#4501 = [#5021]		; save new tool length
					#3502 = [#4501 - #4502]	; Record tool length difference (offset)
					G10 L20 P[#5220] Z[#5003 - #3502]	; set Z-0 offset [Current Z Work]-[measured difference]
					msg "Z Offset: " #3502

				; first tool, record length
				ELSE
					#4501 = [#5021]		; Save new Tool Length measurement value
				ENDIF

				; Move back to previous position if flagged (ex. from z probe sequence)
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
					IF [#4519 == 5] ; move to: 5= previous position
						msg "returning to previous position"
						G53 G0 Z#4506 ; Z Safe Height [Machine]
						G53 G0 X#4514 Y#4515 ; Move to previous XY position
						G53 G1 Z#4516 F1000
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
		#3501 = 0
	ENDIF

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup
	;msg "TCAGuard on Measurement"

    ;Check if ZHeight comp was on before and switch ON again if it was.
    if [[#5026 == 1] OR [#5025 == 1]]
        ZHC on
		G4 P0.5
		#5025 = 0
		;msg "ZHC on commanded by tool measurement"
    ENDIF
ENDSUB
;***************************************************************************************
Sub TOOL_CHANGE_DLG  ; Call Tool Change Sequence

    Dlgmsg "Which Tool should be changed" " New Tool Number:" 5011
    IF [#5398 == 1] ;OK
		IF [#5011 > 99] 
		    Dlgmsg "Tool Number Incorrect: only 1-99"
		    #5011 = #5008 ; [New Tool Number] reset to [current tool number]
			M30
		ELSE
	    	#3510 = 1 ; set FLAG Tool Change initiated from GUI (1= initiated from GUI)
	    	msg "change_tool called from GUI"
			gosub change_tool
		    #3510 = 0 ; Reset FLAG Tool Change initiated from GUI
		ENDIF
    ENDIF
ENDSUB
;***************************************************************************************
Sub TOOL_NBR_UPDATE  ; Update Tool Number
    #5011 = [#5008]
    Dlgmsg "!!! Tool Update !!!" "New Tool Number" 5011 "Current Tool Number" 5008 
    IF [#5011 > 99] 
		Dlgmsg "Tool Number Incorrect: only 0-99"
		#5011 = #5008				; [New Tool Number] reset to [current tool number]
		M30
    ELSE
		#5015 = 1 ; Was tool successfully updated 1=Yes
		IF [[#5011] < 100] 
		    M6 T[#5011]
			msg "Tool # updated to T" #5011
		ENDIF
    ENDIF
ENDSUB
;***************************************************************************************
Sub TOOL_SENSOR_CALIBRATE
    ; Sensor Status check -----------------------------
    GOSUB SENSOR_CHECK
    ;--------------------------------------------------
  	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup
    ;Check ZHeight comp and switch off when on, remember the state in #5025 or #5026, #5151 indicates that ZHeight comp is on    
    #5025 = #5151 ;set temp flag for ZHC status
    if [#5025 == 1]
        ZHC off
		;msg "ZHC off commanded by tool sensor cal"
		G4 P0.5
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
    if [#5025 == 1]
        ZHC on
		G4 P0.5
		;msg "ZHC on commanded by tool sensor cal"
		#5025 = 0
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
   	
	msg "Move to Tool Change Position"
	M9 ; turn off coolant
	M5 ; turn off spindle
	G90
	G53 G0 Z#4506
	G53 G0 X[#4521] Y[#4522]

ENDSUB

Sub TMP ;Move to Tool Measurement Position

   	msg "Move to Tool Measure Position"
	M9 ; turn off coolant
	M5 ; turn off spindle
	G90
	G53 G0 Z#4506
	G53 G0 X[#4507] Y[#4508]

ENDSUB

Sub PROBE_CUTOUT
	; #4000 - material thickness
	; #4001 - baseplate zero after probing
	; #4002 - measured spoilboard height
	; #4003 - expected spoilboard height from baseplate
	; #4004 - material thickness as programmed in GCODE
	
	TCAGuard off ;allow machine into tool change area as defined in TCA setup

    ZHC off
	G4 P0.5

	M9 ; turn off coolant
	M5 ; turn off spindle	
	GOSUB SENSOR_CHECK
   	#5027 = #[5400 + #5008] ; current tool length
	#5028 = #[5500 + #5008] ; current tool diameter
	MSG "CURRENT SPOILBOARD HEIGHT: " [#4002]
	
	
	dlgmsg "set cutout z0 height" "Spoilboard Thickness" 4002 "Material thickness" 4004 "Tool Length:" 5027 "Tool Diameter: " 5028
    
	IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off
     	IF [ [#5027 <= 0] OR [ [#4509 + #5027 + 10] > [#4506] ] ] ;Estimated tool length is negative OR too long for sensor height
            dlgmsg "Length must be between 0 and MAX, ok to restart" "Tool Length: " 5027 "Tool Diameter: " 5028
            IF [#5398 == 1] ;OK pressed
				#[5400 + #5008] = #5027 ; update length if manually changed in dialog
				#[5500 + #5008] = #5028 ; update diameter if manually changed in dialog
				msg "restarting measurement"
				gosub PROBE_CUTOUT
			ELSE
				msg "Cutout probing FAILED"
				#5027 = 0 ; reset tool length
				#5028 = 0 ; reset tool diameter
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
		G53 G0 z[#4509 + #5027 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [recorded Tool Length] + 30 = MCS Z distance
		G38.2 G91 Z-20 F500 	; slow Z minus 20 with probe active in case of crash
	    IF [[#5067 == 1]	AND [#5380 == 0]] ; if sensor triggered and simulation mode is 0
		    G91 G0 Z5
			G90						; G90 -> Absolute distance mode
			;Check if ZHeight comp was on before and switch ON again if it was.
    		if [[#5026 == 1] OR [#5025 == 1]]
		        ZHC on
				G4 P0.5
				;msg "ZHC on commanded by tool measurement"
  			ENDIF
			TCAGuard on ;disallow machine into tool change area as defined in TCA setup
		    errmsg "Measurement aborted! -> Unexpected sensor trigger"
        ENDIF

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
				G10 L20 P[#5220] Z[#4500 - #4002 - #4004] 	; Overwrite current Z height with probe height - Spoilboard height - material height
				msg "Z Height at probe point: " [#4500 - #4002 - #4004]
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
    ZHC off
	G4 P0.5

	M9 ; turn off coolant
	M5 ; turn off spindle	
	GOSUB SENSOR_CHECK
	;update tool
	;M6 T[#5011]				; New Tool Number set
	;msg "changed to Tool " #5011
   	#5027 = #[5400 + #5011] ; new tool length
	#5028 = #[5500 + #5011] ; new tool diameter

	MSG "SPOILBOARD HEIGHT #4002: " [#4002] " MATERIAL HEIGHT: "#4004 " TOOL LENGTH: "#5027
	G4 P3 ;wait 3 sec to read/pause
    #5398=1

	IF [[#5398 == 1] AND [#5397 == 0]]	; OK button was pressed and RENDER Mode is off
		IF [ [#5027 <= 0] OR [ [#4509 + #5027 + 10] > [#4506] ] ] ;Estimated tool length is negative OR too long for sensor height
            dlgmsg "Length must be between 0 and MAX, ok to restart" "Tool Length: " 5027 "Tool Diameter: " 5028
            IF [#5398 == 1] ;OK pressed
				#[5400 + #5011] = #5027 ; update length if manually changed in dialog
				#[5500 + #5011] = #5028 ; update diameter if manually changed in dialog
				msg "restarting measurement"
				gosub PROBE_CUTOUT_AUTO
			ELSE
				msg "Cutout probing FAILED"
				#5027 = 0 ; reset tool length
				#5028 = 0 ; reset tool diameter
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
		G53 G0 z[#4509 + #5027 + 30] 	; Rapid Z to [MCS chuck probe trigger] + [recorded Tool Length] + 30 = MCS Z distance
		G38.2 G91 Z-20 F500 	; slow Z minus 20 with probe active in case of crash
	    IF [[#5067 == 1]	AND [#5380 == 0]] ; if sensor triggered and simulation mode is 0
		    G91 G0 Z5
			G90						; G90 -> Absolute distance mode
			TCAGuard on ;disallow machine into tool change area as defined in TCA setup
		    errmsg "Measurement aborted! -> Unexpected sensor trigger"
        ENDIF
		
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
				G10 L20 P[#5220] Z[#4500 - #4002 - #4004] 	; Overwrite current Z height with probe height - Spoilboard height - material height
				msg "Z Height at probe point: " [#4500 - #4002 - #4004]
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
					GOSUB PROBE_CUTOUT_AUTO
			    ELSE
				errmsg "Measurement failed!"
			    ENDIF
			ENDIF
	ELSE
		msg "Cutout probing aborted"
	ENDIF

	TCAGuard on ;disallow machine into tool change area as defined in TCA setup

ENDSUB

; ------------------------------------------
;   SPINOGY X22 Macros v1.5.2 for EdingCNC
	; ------------------------------------------
	;
	;   SPINOGY GmbH
	;   Brunnenweg 17
	;   64331 Weiterstadt
	;
	;   https://spinogy.de
	;
	; ------------------------------------------
	;
	;   SUPPORTED X22 SPINDLE MODELS:
	;   - CG005 - 25.000 rpm
	;   - CG006 - 30.000 rpm
	;   - CG007 - 35.000 rpm
	;   - CG008 - 40.000 rpm
	;   - CG009 - 45.000 rpm
	;   - CG010 - 50.000 rpm
	;
	; ------------------------------------------
	;
	;   VERSION HISTORY:
	;   - 1.0.0: first version
	;   - 1.1.0: use loops for speed calculation
	;   - 1.2.0: add configuration dialog
	;   - 1.3.0: add ramp up for spindle speeds
	;   - 1.4.0: add graphical dialogs
	;   - 1.5.0: check config against M90 setting
	;   - 1.5.1: first release
	;   - 1.5.2: fixed some typos and message length
	;
	; ------------------------------------------
	;
	;   CONFIGURATION VARIABLES (persistent):
	;   - #4337 - if configured
	;   - #4338 - configured spindle model
	;   - #4339 - configured spindle rpm
	;
	;   USED HELPER VARIABLES (non-persistent):
	;   - #1337 - loop speed counter
	;   - #1338 - loop interval counter
	;   - #1339 - loop ramp counter
	;   - #1340 - calculated rpm
	;
	; ------------------------------------------

	; configuration routine
Sub spinogy_config
    ; dialog message shows dialogPictures/Spinogy_Config.png
    DlgMsg "Spinogy_Config" "Spindle Model" 4338

    If [#5398 == 1]
        ; check if user input is out of range
        If [[#4338 < 5] or [#4338 > 10]]
            ; reset config
            #4337 = 0
            #4338 = 0
            #4339 = 0

            ; dialog message shows dialogPictures/Spinogy_Error.png
            DlgMsg "Spinogy_Error"

            If [#5398 == 1]
                GoSub spinogy_config
            Else
                ErrMsg "Spinogy configuration aborted."
            EndIf
        Else
            If [#4338 == 5]
                #4339 = 25000
                #4337 = 1

                Msg "Configured Spindle: SPINOGY X22 CG005 / 25.000 rpm"
            EndIf

            If [#4338 == 6]
                #4339 = 30000
                #4337 = 1

                Msg "Configured Spindle: SPINOGY X22 CG006 / 30.000 rpm"
            EndIf

            If [#4338 == 7]
                #4339 = 35000
                #4337 = 1

                Msg "Configured Spindle: SPINOGY X22 CG007 / 35.000 rpm"
            EndIf

            If [#4338 == 8]
                #4339 = 40000
                #4337 = 1

                Msg "Configured Spindle: SPINOGY X22 CG008 / 40.000 rpm"
            EndIf

            If [#4338 == 9]
                #4339 = 45000
                #4337 = 1

                Msg "Configured Spindle: SPINOGY X22 CG009 / 45.000 rpm"
            EndIf

            If [#4338 == 10]
                #4339 = 50000
                #4337 = 1

                Msg "Configured Spindle: SPINOGY X22 CG010 / 50.000 rpm"
            EndIf

            ; check if eding cnc M90 setting is correctly configured, based on the spindle setting
            If [#5394 < #4339]
                WarnMsg "Your configured max spindle speed ("#5394") in M90 is lower than your configured spindle speed ("#4339"). Please check."
            EndIf
        EndIf
    Else
        Msg "Spinogy configuration aborted."
    EndIf
EndSub

; special routine for warmup spinogy x22 spindles
Sub spinogy_warmup
    ; dialog message shows dialogPictures/Spinogy_Warmup.png
    DlgMsg "Spinogy_Warmup"

    If [#5398 == 1]
        ; used routine variables
        #1337 = 0 ; loop speed counter
        #1339 = 0 ; loop ramp counter
        #1340 = 0 ; calculated rpm

        Msg "Starting Spinogy spindle warmup ..."
		M8
        ; move z up
        Msg "Move Z to safe position ..."
        G53 G0 Z0

        ; loop 4 times to increment speed
        While [#1337 < 4]
            ; calculate destination speed
            #1340 = [[#1337 + 1] * 6]

            Msg "Ramp up spindle to "#1340".000 rpm and then hold for 5 minutes ..."

            ; loop 3 times to ramp up spindle rpm
            #1339 = 3
            While [#1339 > 0]
                Msg "Ramp up for 7 seconds ..."

                ; increase by 1500 rpm in 7 second steps
                M3 S[[#1340 * 1000] - [#1339 * 1500]]
                G4 P[7]

                ; decrement counter
                #1339 = [#1339 - 1]
            EndWhile

            ; start spindle at desired rpm and run for 5 minutes
            Msg "Hold "#1340".000 rpm for 5 minutes ..."
            M3 S[#1340 * 1000]
            G4 P[60 * 5]

            ; increment counter
            #1337 = [#1337 + 1]
        EndWhile

        ; finished warmup and stop spindle
        M5
        Msg "Spinogy spindle warmup finished!"
    EndIf
EndSub

; special routine for spinogy x22 to evenly distribute grease
Sub spinogy_greaserun
    If [#4337 <> 1]
        ErrMsg "Please run Spinogy configuration first."
    EndIf

    ; dialog message shows dialogPictures/Spinogy_Greaserun.png
    DlgMsg "Spinogy_Greaserun"

    If [#5398 == 1]
        ; used routine variables
        #1337 = 0 ; loop speed counter
        #1338 = 0 ; loop interval counter
        #1339 = 0 ; loop ramp counter
        #1340 = 0 ; calculated rpm

        Msg "Starting Spinogy grease distribution run ..."
		M8
        ; move z up
        Msg "Move Z to safe position ..."
        G53 G0 Z0

        ; ---------
        ; phase one
        ; ---------

        ; loop 3 times to increment speed
        While [#1337 < 3]
            ; calculate speed
            #1340 = [[#1337 + 1] * 8]

            ; loop 4 times for intervals
            #1338 = 0
            While [#1338 < 4]
                Msg "Ramp up spindle to "#1340".000 rpm and then hold for 1 minutes ..."

                ; loop 3 times to ramp up spindle rpm
                #1339 = 3
                While [#1339 > 0]
                    Msg "Ramp up for 5 seconds ..."

                    ; increase by 2000 rpm in 5 second steps
                    M3 S[[#1340 * 1000] - [#1339 * 2000]]
                    G4 P[5]

                    ; decrement counter
                    #1339 = [#1339 - 1]
                EndWhile

                ; start spindle at desired rpm and run for 1 minutes
                Msg "Hold "#1340".000 rpm for 1 minute ..."
                M3 S[#1340 * 1000]
                G4 P[60 * 1]

                ; turn off spindle and wait 2 minutes
                Msg "Pause for 2 minutes ..."
                M5
                G4 P[60 * 2]

                ; increment counter
                #1338 = [#1338 + 1]
            EndWhile

            ; increment counter
            #1337 = [#1337 + 1]
        EndWhile

        ; ---------
        ; phase two
        ; ---------

        Msg "Ramp up spindle to 24.000 rpm and then hold for 30 minutes ..."

        ; loop 3 times to ramp up spindle rpm
        #1339 = 0
        While [#1339 < 3]
            Msg "Ramp up for 5 seconds ..."

            ; increase by 6000 rpm in 5 second steps
            M3 S[[#1339 + 1] * 6000]
            G4 P[5]

            ; increment counter
            #1339 = [#1339 + 1]
        EndWhile

        ; start spindle at 24.000 rpm and run for 30 minutes
        Msg "Turn spindle at 24.000 rpm for 30 minutes ..."
        M03 S24000
        G04 P[60 * 30]

        ; turn off spindle and wait 5 minutes
        Msg "Pause for 5 minutes ..."
        M05
        G04 P[60 * 5]

        Msg "Ramp up spindle to "[#4339 / 1000]".000 rpm and then hold for 30 minutes ..."

        ; loop 6 times to ramp up spindle rpm
        #1339 = 0
        While [#1339 < 7]
            Msg "Ramp up for 3 seconds ..."

            ; increase by 1/6 of the configured max rpm in 3 second steps
            M3 S[[#1339 + 1] * [#4339 / 7]]
            G4 P[3]

            ; increment counter
            #1339 = [#1339 + 1]
        EndWhile

        ; turn spindle at configured maximum rpm for 30 minutes
        Msg "Turn spindle at "[#4339 / 1000]".000 rpm for 30 minutes ..."
        M03 S[#4339]
        G04 P[60 * 30]

        ; finished run and stop spindle
        M05
        Msg "Spinogy spindle grease run finished!"
    EndIf
EndSub

;***************************************************************************************
; Configuration Macros
;***************************************************************************************
sub config
	GoSub CFG_TOOLCHANGEPOS
	gosub CFG_TLOPROBE
	GoSub CFG_ZPROBE
	GoSub CFG_TOOLMEASUREPOS
	GOSUB CFG_SPOILBOARD
	;GoSub CFG_3DPROBE
ENDSUB
;***************************************************************************************
sub CFG_TOOLCHANGEPOS
	;0= Ignore, 1 = Skip measurement, 2= Measure
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
	Dlgmsg "Position after Tool Measurement" "Position 0-4" 4519 "Mode 0 X-Axis Pos(MCS)" 4524 "Mode 0 Y-Axis Pos(MCS)" 4525 
 
	;#4519 What to do after Tool Length Measurement: 
	;0= pre defined point
	;1= Work 0
	;2= Tool Change Position
	;3= Machine 0
	;4= Remain in place
	;#4524 Position X after Tool Length Measurement   
	;#4525 Position Y after Tool Length Measurement
	
ENDSUB

SUB CFG_SPOILBOARD
	Dlgmsg "Spoilboard Height" "spoilboard thickness: " 4002
ENDSUB
;***************************************************************************************


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
