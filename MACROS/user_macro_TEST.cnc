;***************************************************************************************
; User Macros
;
; You can make these fit your software button layout by simply placing the desired subroutine under the corresponding "user_x" header. 
; The below layout matches the "macro.cnc" file and icons contained in the icon folder
;
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
Sub user_14 ; 3D probe
   	GOSub 3D_menu
ENDSUB
;***************************************************************************************
Sub user_15 ; Set Z height to match material thickness
   	GOSub PROBE_CUTOUT
ENDSUB
;***************************************************************************************
Sub user_16 ; Move Z to 1
   	GOSub LOWER_Z
ENDSUB
;***************************************************************************************
Sub user_17 ; Move to WCS 0 Z5
   	GOSub WCS0_Z5
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

SUB xhc_start_pause
	msg"Handwheel called start pause"
ENDSUB

SUB xhc_probe_z ; Probe Z height
   	msg "Probing called from handwheel"
	#3505 = 1	; FLAG whether Tool Length Measurement called from handwheel 1=Handwheel
	gosub Z_PROBE ; Probe Z height
ENDSUB
;***************************************************************************************
SUB xhc_macro_1
	msg"WCS XY0 set from handwheel"
	G10L20P1X0Y0
ENDSUB

SUB xhc_macro_5
	g28 ; Move to Machine 0 (Home)
ENDSUB

SUB xhc_macro_6
	msg"Handwheel called move to TCP"
	gosub TCP ;Move to Tool Change Position
ENDSUB

SUB xhc_macro_7
	msg"Handwheel called Tool Change"
	GOSUB TOOL_CHANGE_DLG
ENDSUB

SUB xhc_macro_8
	msg"Handwheel called move to TMP"
	gosub TMP ;Move to Tool Measurement Position
ENDSUB

SUB xhc_macro_9
	msg"Tool Length Measurement"
	gosub TOOL_MEASURE ;Tool Length Measurement
ENDSUB

