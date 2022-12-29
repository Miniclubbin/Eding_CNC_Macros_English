;***************************************************************************************
; User Macros
;***************************************************************************************
Sub user_1 ; Probe for Work Z-zero height
    GOSUB Z_PROBE	
ENDSUB
;***************************************************************************************
Sub user_2 ; Tool Length Measurement
	GOSUB TOOL_MEASURE
ENDSUB
;***************************************************************************************
Sub user_3 ; Tool change dlg
	GOSUB TOOL_CHANGE_DLG
ENDSUB
;***************************************************************************************
Sub user_4 ; Move to Machine 0 (Home)
	GOSUB MOVE_Machine0
ENDSUB
;***************************************************************************************
Sub user_5 ; Tool Number Update
	GOSUB TOOL_NBR_UPDATE
ENDSUB
;***************************************************************************************
Sub user_6 ; Probe for Z0, offset by .1mm for VCarve tolerance
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
Sub user_11 ; Z Safe
	GOSub RAISE_Z
ENDSUB
;***************************************************************************************
Sub user_12 ; MOVE_Machine0
	GOSub MOVE_Machine0 ; Move to Machine 0 (Home)
ENDSUB
;***************************************************************************************
Sub user_13 ; Move to WCS 0 Safe Z
   	GOSub WCS_0
ENDSUB
;***************************************************************************************
Sub user_14 ; Move to WCS 0 Z5
   	GOSub WCS0_Z5
ENDSUB
;***************************************************************************************
Sub user_15 ; Move Z to 1
   	GOSub LOWER_Z
ENDSUB
;***************************************************************************************
Sub user_16 ; NONE
   	msg "sub user_16"
	DlgMsg "No function assigned"
ENDSUB
;***************************************************************************************
Sub user_17 ; NONE
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

;***************************************************************************************
; Handwheel Macros
;***************************************************************************************
SUB xhc_probe_z ; Probe Z height
	#3505 = 1	; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
	gosub Z_PROBE ; Probe Z height
ENDSUB
;***************************************************************************************
SUB xhc_macro_9 ;Tool Length Measurement
	msg"Tool Length Measurement"
	gosub TOOL_MEASURE ;Tool Length Measurement
ENDSUB
