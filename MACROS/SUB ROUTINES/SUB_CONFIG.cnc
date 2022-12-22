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