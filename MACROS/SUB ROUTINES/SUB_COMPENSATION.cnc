;***************************************************************************************
; Compensation Macros
;***************************************************************************************
Sub zero_set_rotation
	;---------------------------------------------------------------------------------------
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
	ENDIF
	g68 R#5024
	msg "G68 R"#5024" applied, now zero XYZ normally"
	msg "Remove probe IF used"
ENDSUB

;***************************************************************************************
sub zhcmgrid ; Surface Probing
    ;probe scanning routine for eneven surface milling
	;---------------------------------------------------------------------------------------

	;scanning starts at WCS x=0, y=0
	IF [#4100 == 0]
		#4100 = 10  ;number x points
		#4101 = 5   ;number y points
		#4102 = 40  ;max z height
		#4103 = 10  ;min z height
		#4104 = 10.0 ;grid point distance (mm)
		#4105 = 100 ;probing feed
	ENDIF    

	#110 = 0    ;Actual nx
	#111 = 0    ;Actual ny
	#112 = 0    ;Missed measurements counter
	#113 = 0    ;Number of points added
	#114 = 1    ;0: odd x row, 1: even xrow
	;Dialog
	dlgmsg "Surface Grid Probing" "number of x points" 4100 "number of y points" 4101 "max (clearance) Z height" 4102 "min Z height" 4103 "grid point distance" 4104 "Feed" 4105 
   
	IF [#5398 == 1] ; user pressed OK
    	;Move to startpoint
    	G0 z[#4102];to upper Z
    	G0 X0 Y0 ;to start point
    	ZHCINIT [#4104] [#4100] [#4101] ;ZHCINIT gridSize nx ny
    	#111 = 0    ;Actual ny value
    	WHILE [#111 < #4101]
        	IF [#114 == 1]
          		;even x row, go from 0 to nx
          		#110 = 0 ;start nx
          		WHILE [#110 < #4100]
            		;Go up, goto xy, measure
            		G0 z[#4102];to upper Z
            		G0 x[#110 * #4104] y[#111 * #4104] ;to new scan point
            		G38.2 F[#4105] z[#4103];probe down until touch   
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
            		G0 x[#110 * #4104] y[#111 * #4104] ;to new scan point
            		g38.2 F[#4105] z[#4103];probe down until touch  
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
    	G0 z[#4102];to upper Z
    	ZHCS zHeightCompTable.txt ;Save measured table
    	msg "Done, "#113" points added, "#112" not added" 
  	ELSE
    	;user pressed cancel in dialog
    	msg "Operation canceled"
  	ENDIF
ENDSUB
;---------------------------------------------------------------------------------------