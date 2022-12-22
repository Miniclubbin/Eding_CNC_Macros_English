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