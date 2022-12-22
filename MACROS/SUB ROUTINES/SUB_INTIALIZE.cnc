;Variables used

	;   #3500 INIT
	;   #4504 TLO Fast probing feed (mm/min)
	;   #4505 TLO Slow probing feed for exact measurement (mm/min)
	;   #4511 Clearance Height
	;   #4512 Z Fast probing feed (mm/min)
	;	#4513 Z Slow probing feed for exact measurement (mm/min)

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