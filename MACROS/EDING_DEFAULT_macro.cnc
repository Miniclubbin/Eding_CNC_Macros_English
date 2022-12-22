;*****************************************
;* This is file macro.cnc version changed at V4.03.20
;* It is automatically loaded
;* Customize this file yourself if you like
;* It contains:
;* - subroutine change_tool this is called on M6T..
;* - subroutine home_x .. home_z, called when home functions in GUI are activated
;* - subroutine home_all, called when home all button in GUI are activated
;* - subroutine user_1 .. user_11, called when user functions are activated
;*   user_1 contains an example of zeroing Z using a moveable tool setter
;*   user_2 contains an example of measuring the tool length using a fixed tool setter
;*
;* You may also add frequently used macro's in this file.
;****************************************


;* #4995 = ...  ;(Variable tool setter height for zeroing Z, used in zero_z)
;* #4996 = ...  ;(Tool measurement safe hight, used inside m_tool)
;* #4997 = ...  ;(X position of tool length measurement)
;* #4998 = ...  ;(Y position of tool length measurement)
;* #4999 = ...  ;(Chuck height, or zero - tool length height)




Sub zero_z

  #4995 = 43      ;set value for compatibility with previous macro.cnc

  if [[#5380==0] and [#5397==0]] ;do this only when not simulating and not rendering
    msg "user_1, Zero Z (G92) using tool-setter"
    (Start probe move, slow)
    f30
    g53 g38.2 z[#5103 + #4995] ;Probe move, not below variable tool setter height
    (Move back to touch point)
    g90 g0 z#5063
    (Set position, the measuring device is 43mm in height, adapt for your measuring device)
    G92 z#4995
    (move 5 mm above measuring device)
    g91 (incremental distance mode)
    g0 z5
    g90 (absolute distance mode)
  endif
Endsub

sub m_tool
    if [[#5380==0] and [#5397==0]] ;do this only when not simulating and not rendering
        ;Check if toolsetter is calibrated
        if [[#4996 == 0] and [#4997 == 0] and [#4998 == 0] and [#4999 == 0]]
            errmsg "calibrate first, MDI: gosub calibrate_tool_setter"
        else
            g0 g53 z#4996 ; move to safe z
            dlgmsg "enter tool dimensions" "tool number" 5016 "approx tool length" 5017 "tool diameter" 5018
            ;Check user pressed OK
            if [#5398 == 1] 
                if [[#5016 < 1] OR [#5016 > 99]]
                    ErrMsg "Tool must be in range of 0 .. 99"
                endif
        
                ;move to toolsetter coordinates
                g00 g53 x#4997 y#4998 
                ;move to 10mm above chuck height + approx tool length + 10
                g00 g53 z[#4999+10+#5017]
                ;measure tool length and pull 5mm back up
                g38.2 g91 z-20 f30
                g90
                ;back to safe height
                g0 g53 z#4996
                ;Store tool length, diameter in tool table
                ;but only if actually measured, 
                ;so leave tool table as is while rendering 
                if [#5397 == 0]
                    #[5400 + #5016] = [#5053-#4999]
                    #[5500 + #5016] = #5018
                    #[5600 + #5016] = 0 ;Tool X offset is 0
                    msg "tool length measured="#[5400 + #5016]" stored at tool "#5016
                endif
            endif
        endif
    endif
endsub

;Same but no dialog
;Tool number is set in 5025
;Tool length an diameter is retrieved from tool table.
;Warning the length in the tool table must not be 10 mm or more shorter as the tool,
;Otherwise collision with the tool-setter will happen!!!!!!!
sub m_tool_no_dlg
    if [[#5380==0] and [#5397==0]] ;do this only when not simulating and not rendering
        ;Check if toolsetter is calibrated
        if [[#4996 == 0] and [#4997 == 0] and [#4998 == 0] and [#4999 == 0]]
            errmsg "calibrate first, MDI: gosub calibrate_tool_setter"
        else
            
            ;dlgmsg "enter tool dimensions" "tool number" 5016 "approx tool length" 5017 "tool diameter" 5018
            
            ;In stead of the dialog we get the values from the tool table.
            #5016 = #5025           ;Tool number
            #5017 = #[5400 + #5016] ;Approx tool-length from tool table
            #5018 = #[5500 + #5016] ;Tool diameter from tool table
                        
            if [[#5016 < 1] OR [#5016 > 99]]
                ErrMsg "Tool must be in range of 0 .. 99"
            endif
            
            ;Check if tool is loaded, if not do so.
            if [#5016 <> #5008]
                m6 t#5016
            endif
    
            g0 g53 z#4996 ; move to safe z
            ;move to toolsetter coordinates
            g00 g53 x#4997 y#4998 
            ;move to 10mm above chuck height + approx tool length + 10
            g00 g53 z[#4999+10+#5017]; change this to g00 g53 z[#5113] to go fully up.
            ;measure tool length and pull 5mm back up
            g38.2 g91 z-20 f30
            g90
            ;back to safe height
            g0 g53 z#4996
            ;Store tool length, diameter in tool table
            ;but only if actually measured, 
            ;so leave tool table as is while rendering 
            if [#5397 == 0]
                #[5400 + #5016] = [#5053-#4999]
                #[5500 + #5016] = #5018
                #[5600 + #5016] = 0 ;Tool X offset is 0
                msg "tool length measured="#[5400 + #5016]" stored at tool "#5016
            endif
        endif
    endif
endsub


;Example to enumerate tools used in a job end measure them using a dialogue
;Can e.g. be used to measure the length of all tools at once before running the job.
;This example is made for maximum 6 tools.
sub measure_used_tools
    GetToolInfo num 5025 ;get the number of tools used in the loaded g-code.
    Msg "number of tools used = " #5025
    
    ;Initialise our tool Array (6 tools)
    #5026 = 0 ;Used as counter, tool 0 .. 6
    While [#5026 <= 6]
        #[5030 + #5026] = 0
        #5026 = [#5026 + 1]
    endwhile
    ;#5030 .. #5036 is now 0
    
    ;Get all used tools an set it to 1 in array which goes from #5030 to #5036
    GetToolInfo first 5025
    while [[#5025 >= 0] and [#5025 <= 6]] ;#5025 becomes -1 at last tool.
        msg "Tool "#5025" is used"
        ;Store in array
         #[5030 + #5025] = 1
        GetToolInfo next 5025
    endwhile
    
    ;Suppose maximum tools in the machine is 6
    ;We ask the customer which tool to measure and set the used ones e default as yes (1)
    dlgmsg "Select tools to measure 1 => YES 0 => NO)" "tool 1" 5031 "tool 2" 5032 "tool 3" 5033 "tool 4" 5034 "tool 5" 5035 "tool 6" 5036
    
     if [#5398 == 1] ; user pressed ok
     
        msg "starting tool measurement"
        G4 P1 ;Wait 1 sec to show message

        ;Perform tool measurement for all selected tools
        #5026 = 0 ;Used as counter, tool 0 .. 6
        While [#5026 <= 6]
            if [#[5030 + #5026] == 1]
                #5025 = #5026 
                gosub m_tool_no_dlg
            else
                ;skip because it was not selected
            endif
            #5026 = [#5026 + 1] ; next
        endwhile
        
     else
        ;User pressed cancel in the dialog
        msg "measurement cancelled"
     endif
    
endsub


;* calibrate tool length measurement position and hight.
;* variables #4996 - #4999 are set to be used in m_tool.
Sub calibrate_tool_setter
    warnmsg "close MDI, check correct calibr. tool nr 99 in tool table, press ctrl-g"
    warnmsg "jog to toolchange safe height, when done press ctrl-g"
    #4996=#5073 ;Store toolchange safe height machine coordinates
    warnmsg "insert cal. tool 99 len="#5499", jog above tool setter, press ctrl-g"
    ;store x y in non volatile parameters (4000 - 4999)
    #4997=#5071 ;machine pos X
    #4998=#5072 ;machine pos Y
    ;Determine minimum toochuck height and store into #4999
    g38.2 g91 z-20 f30
    #4999=[#5053 - #5499] ;probepos Z - calibration tool length = toolchuck height
    g90
    g0 g53 z#4996
    msg "calib. done safe height="#4996 " X="#4997 " Y="#4998 " Chuck height="#4999
endSub

;User functions, F1..F11 in user menu

;Zero tool tip example
Sub user_1
    msg "user_1, Zero Z using toolsetter"
    gosub zero_z
Endsub

;Tool length measurement example
Sub user_2
    goSub m_tool ;See sub m_tool
Endsub

Sub user_3 ;Example of dlgmsg
    #1 = 0
    #2 = 0
    #3 = 0
    #4 = 0
    #5 = 0
    #6 = 0
    #7 = 0
    #8 = 0
    #9 = 0
    #10 = 0
    #11 = 0
    #12 = 0
    ;dlgmsg will popup a dialog with picture edingcnc.png from c:\program files (x86)\cnc4.01\dialogPictures directory
        dlgmsg "edingcnc" "A" 1 "B" 2 "C" 3 "D" 4 "E" 5 "F" 6 "G" 7 "H" 8 "I" 9 "J" 10 "K" 11 "L" 12 "M" 13 "N" 14 "O" 15
    if [#5398 == 1]
        msg "OK #1="#1 "#2="#2 "#3="#3 "#4="#4 "#5="#5 "#6="#6 "#7="#7 "#8="#8 "#9="#9 "#10="#10 "#11="#11 "#12="#12 "#13="#13 "#14="#14 "#15="#15
    else
        msg "CANCEL #1="#1 "#2="#2 "#3="#3 "#4="#4 "#5="#5 "#6="#6 "#7="#7 "#8="#8 "#9="#9 "#10="#10 "#11="#11 "#12="#12 "#13="#13 "#14="#14 "#15="#15
    endif
Endsub

Sub user_4
    gosub measure_used_tools
Endsub

Sub user_5
    msg "sub user_5"
Endsub

Sub user_6
    msg "sub user_6"
Endsub

Sub user_7
    msg "sub user_7"
Endsub

Sub user_8
    msg "sub user_8"
Endsub

Sub user_9
    msg "sub user_9"
Endsub

Sub user_10
    msg "sub user_10"
Endsub

Sub user_11
    msg "sub user_11"
Endsub

;Homing per axis
Sub home_x
    home x
    ;;if A is slave of X uncomment next lines and comment previous line
    ;homeTandem X
Endsub

Sub home_y
    home y
Endsub

Sub home_z
    home z
Endsub

Sub home_a
    ;;If a is slave comment out next line
    ;;For homing a master-slave axis only homeTandem <master> should be done
    home a
Endsub

Sub home_b
    home b
Endsub

Sub home_c
    home c
Endsub

;Home all axes, uncomment or comment the axes you want.
sub home_all
    gosub home_z
    gosub home_y
    gosub home_x
    gosub home_a
    gosub home_b
    gosub home_c
    msg "Home complete"
endsub

Sub zero_set_rotation
    msg "move to first point, press control-G to continue"
    m0
    #5020 = #5071 ;x1
    #5021 = #5072 ;y1
    msg "move to second point, press control-G to continue"
    m0
    #5022 = #5071 ;x2
    #5023 = #5072 ;y2
    #5024 = ATAN[#5023 - #5021]/[#5022 - #5020]
    if [#5024 > 45]
      #5024 = [#5024 - 90] ;points are in Y direction
    endif
    g68 R#5024
    msg "G68 R"#5024" applied, now zero XYZ normally"
Endsub

;This example shows how to make your own tool_changer work.
;It is made for 6 tools
;First current tool is dropped, then the new tool is picked
;There is a check whether selected tool is already in the spindle
;Also a check that the tool is within 1-6
;There is a picktool subroutine for each tool and a droptool subroutine for each tool.
;These routines need to be modified to fit your machine and tool changer

sub change_tool
    ;Switch off guard for tool change area collision
    TCAGuard off 

    ;Check ZHeight comp and switch off when on, remember the state in #5019
    ;#5151 indicates that ZHeight comp is on    
    #5019 = #5151
    if [#5019 == 1]
        ZHC off
    endif
    
   ;Switch off spindle
    m5

    ;Use #5015 to indicate succesfull toolchange
    #5015 = 0 ; Tool change not performed

    ; check tool in spindle and exit sub
    If [ [#5011] <> [#5008] ]
        if [[#5011] > 6 ]
            errmsg "Please select a tool from 1 to 6." 
        else
            ;Drop current tool
            If [[#5008] == 0] 
                GoSub DropTool0
            endif
            If [[#5008] == 1] 
                GoSub DropTool1
            endif
            If [[#5008] == 2] 
                GoSub DropTool2
            endif
            If [[#5008] == 3] 
                GoSub DropTool3
            endif
            If [[#5008] == 4] 
                GoSub DropTool4
            endif
            If [[#5008] == 5] 
                GoSub DropTool5
            endif
            If [[#5008] == 6] 
                GoSub DropTool6
            endif
            
            ;Pick new tool
            if [[#5011] == 0]
                GoSub PickTool0
            endif
            if [[#5011] == 1]
                GoSub PickTool1
            endif
            if [[#5011] == 2]
                GoSub PickTool2
            endif
            if [[#5011] == 3]
                GoSub PickTool3
            endif
            if [[#5011] == 4]
                GoSub PickTool4
            endif
            if [[#5011] == 5]
                GoSub PickTool5
            endif
            if [[#5011] == 6]
                GoSub PickTool6
            endif

        endif
    else
        msg "Tool already in spindle"
        #5015 = 1 ;indicate tool change performed
    endif    
                
    If [[#5015] == 1]   
        msg "Tool "#5008" Replaced by tool "#5011" G43 switched on"
        m6t[#5011]

        if [#5011 <> 0]
            G43  ;we use tool-length compensation.
        else
            G49  ;tool length compensation off for tool 0.
        endif
    else
        errmsg "tool change failed"
    endif
        
    ;Set default motion type to G1   
    g1
    
    ;Switch on guard for tool change area collision
    TCAGuard on
    
    ;Check if ZHeight comp was on before and switch ON again if it was.
    if [#5019 == 1]
        ZHC on
    endif
        
EndSub      
     


;Drop tool subroutines
Sub DropTool0
    ;Tool 0 is nothing, we could open the tool 
    ;magazine here if needed for the following PickTool
    msg "Dropping tool 0"
endsub

Sub DropTool1
    msg "Dropping tool 1"
endsub

Sub DropTool2
    msg "Dropping tool 2"
endsub

Sub DropTool3
    msg "Dropping tool 3"
endsub

Sub DropTool4
    msg "Dropping tool 4"
endsub

Sub DropTool5
    msg "Dropping tool 5"
endsub

Sub DropTool6
    msg "Dropping tool 6"
endsub



;Pick tool subroutines
Sub PickTool0
    msg "Picking tool 0"
    ;Tool 0 is nothing, so we just close the 
    ;tool magazine here if needed.
    #5015 = 1 ; toolchange succes
endsub

Sub PickTool1
    msg "Picking tool 1"
    #5015 = 1 ; toolchange succes
endsub

Sub PickTool2
    msg "Picking tool 2"
    #5015 = 1 ; Tool change succes
endsub

Sub PickTool3
    msg "Picking tool 3"
    #5015 = 1 ; Tool change succes
endsub

Sub PickTool4
    msg "Picking tool 4"
    #5015 = 1 ; Tool change succes
endsub

Sub PickTool5
    msg "Picking tool 5"
    #5015 = 1 ; toolchange succes
endsub

Sub PickTool6
    msg "Picking tool 6"
    #5015 = 1 ; Tool change succes
endsub




sub zhcmgrid
;;;;;;;;;;;;;
;probe scanning routine for eneven surface milling
;scanning starts at x=0, y=0

  if [#4100 == 0]
   #4100 = 10  ;nx
   #4101 = 5   ;ny
   #4102 = 40  ;max z 
   #4103 = 10  ;min z 
   #4104 = 1.0 ;step size
   #4105 = 100 ;probing feed
  endif    

  #110 = 0    ;Actual nx
  #111 = 0    ;Actual ny
  #112 = 0    ;Missed measurements counter
  #113 = 0    ;Number of points added
  #114 = 1    ;0: odd x row, 1: even xrow

  ;Dialog
  dlgmsg "gridMeas" "nx" 4100 "ny" 4101 "maxZ" 4102 "minZ" 4103 "gridSize" 4104 "Feed" 4105 
    
  if [#5398 == 1] ; user pressed OK
    ;Move to startpoint
    g0 z[#4102];to upper Z
    g0 x0 y0 ;to start point
        
    ;ZHCINIT gridSize nx ny
    ZHCINIT [#4104] [#4100] [#4101] 
    
    #111 = 0    ;Actual ny value
    while [#111 < #4101]
        if [#114 == 1]
          ;even x row, go from 0 to nx
          #110 = 0 ;start nx
          while [#110 < #4100]
            ;Go up, goto xy, measure
            g0 z[#4102];to upper Z
            g0 x[#110 * #4104] y[#111 * #4104] ;to new scan point
            g38.2 F[#4105] z[#4103];probe down until touch
                    
            ;Add point to internal table if probe has touched
            if [#5067 == 1]
              ZHCADDPOINT
              msg "nx="[#110 +1]" ny="[#111+1]" added"
              #113 = [#113+1]
            else
              ;ZHCADDPOINT
              msg "nx="[#110 +1]" ny="[#111+1]" not added"
              #112 = [#112+1]
            endif

            #110 = [#110 + 1] ;next nx
          endwhile
          #114=0
        else
          ;odd x row, go from nx to 0
          #110 = [#4100 - 1] ;start nx
          while [#110 > -1]
            ;Go up, goto xy, measure
            g0 z[#4102];to upper Z
            g0 x[#110 * #4104] y[#111 * #4104] ;to new scan point
            g38.2 F[#4105] z[#4103];probe down until touch
                    
            ;Add point to internal table if probe has touched
            if [#5067 == 1]
              ZHCADDPOINT
              msg "nx="[#110 +1]" ny="[#111+1]" added"
              #113 = [#113+1]
            else
              ;ZHCADDPOINT
              msg "nx="[#110 +1]" ny="[#111+1]" not added"
              #112 = [#112+1]
            endif

            #110 = [#110 - 1] ;next nx
          endwhile
          #114=1
        endif
	  
      #111 = [#111 + 1] ;next ny
    endwhile
        
    g0 z[#4102];to upper Z
    ;Save measured table
    ZHCS zHeightCompTable.txt
    msg "Done, "#113" points added, "#112" not added" 
        
  else
    ;user pressed cancel in dialog
    msg "Operation canceled"
  endif
endsub

;Remove comments if you want additional reset actions
;when reset button was pressed in UI
;sub user_reset
;    msg "Ready for operation"
;endsub 

;The 4 subroutines below can be used to add extra code
;add the beginning and end for engrave or laser_engrave
sub laser_engrave_start
  msg "laser_engrave_start"
endsub

sub laser_engrave_end
  msg "laser_engrave_end"
endsub

sub engrave_start
  msg "laser_engrave_start"
endsub

sub engrave_end
  msg "laser_engrave_end"
endsub


; Functions below are used with sheetCAM 
; postprocessor Eding CNC plasma with THC-V2.scpost
sub thcOn
  m20
endsub

sub thcOff
  m21
endsub

sub thcPenDown
  gosub thcReference ; Determine zero pint always at start
  G0 Z4 ; 4 is pierce height. 0 is material surface.
  M3    ; plasma on
  G4 P3 ; pierce delay
endSub

sub thcPenUp
  m5    ; Plasma off
  g4 p1 ; end delay
endsub


sub thcReference
  if [[#5380 == 0] and [#5397 == 0]] ;Probe only when running
    G53 G38.2 Z[#5103+1] F50 ;lowest point 1 mm above negative Z limit with low Feed
    G0 Z[#5063] ;move back to toch point
    G92 Z0 ;Use 0 if the totch itself touches the material, otherwise use the switch offset
  endif
endsub

; The start subroutine is called when a job is started
sub start
  ; msg "start macro called"
endsub
