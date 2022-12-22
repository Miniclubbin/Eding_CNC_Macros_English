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