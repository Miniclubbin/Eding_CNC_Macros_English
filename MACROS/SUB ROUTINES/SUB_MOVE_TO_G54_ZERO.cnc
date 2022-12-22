; Call moves to XY0 Z5 for different workspaces

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