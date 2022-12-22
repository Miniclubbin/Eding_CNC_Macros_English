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