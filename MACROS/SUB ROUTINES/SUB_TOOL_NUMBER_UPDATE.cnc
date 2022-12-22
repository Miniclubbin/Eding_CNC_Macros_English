;***************************************************************************************
Sub TOOL_NBR_UPDATE  ; Update Tool Number
	;---------------------------------------------------------------------------------------
    #5011 = [#5008]
    Dlgmsg "!!! Tool Update !!!" "Current Tool Number" 5008" New Tool Number" 5011
    IF [#5011 > 99] 
		Dlgmsg "Tool Number Incorrect: Please enter Tool Number 1-99"
		#5011 = #5008					; New Tool Number reset to original
		M30
    ELSE
		#5015 = 1					; Was tool successfully updated 1=Yes
		IF [[#5011] > 0] 
		    M6 T[#5011]
		    ;G43
		ELSE
		    M6 T[#5011]
		ENDIF
    ENDIF
ENDSUB