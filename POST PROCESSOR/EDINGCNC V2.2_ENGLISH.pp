+=======================================================
+
+ Vectric machine output configuration file
+ Post-Processor for Vectric after Version 9.5
+ Post-Processor for EdingCNC(V4)
+
+=======================================================
+
+ History
+
+ Author        DD/MM/YYYY   Changes
+ ========      ===========  ================================
+ DJ-Bino       23/12/2013   PP written
+ DJ-Bino       23/12/2013   Arcs and circular moves
+ DJ-Bino       23/12/2013   Revamped for EdingCNC(V4)
+ DJ-Bino       06/07/2014   Spindle Speed 
+ DJ-Bino       06/07/2014   Dwell time 
+ DJ-Bino       17/05/2018   Tool name 
+ DJ-Bino       14/09/2018   Helix moves G02/G03
+ DJ-Bino       19/06/2020	 Safe Z height G53/G28
+ MiniClubbin   19/12/2022   Translated to English, trimmed "new segment" lines to speed up gcode
+ MiniClubbin   21/12/2022   REMOVED G54 from HEADER block to allow for multiple work offsets
+=======================================================

POST_NAME = "EDINGCNC V2.2 (*.nc)"

FILE_EXTENSION = "NC"

UNITS = "MM"

RAPID_PLUNGE_TO_STARTZ = "YES"


+------------------------------------------------
+    Line terminating characters
+------------------------------------------------

LINE_ENDING = "[13][10]"

+------------------------------------------------
+    Block numbering
+------------------------------------------------

LINE_NUMBER_START     = 5
LINE_NUMBER_INCREMENT = 5
LINE_NUMBER_MAXIMUM = 9999999

+================================================
+
+    Formatting for variables
+
+================================================

VAR LINE_NUMBER = [N|A|N|1.0]
VAR SPINDLE_SPEED = [S|A|S|1.0]
VAR FEED_RATE = [F|C|F|1.1]
VAR X_POSITION = [X|C|X|1.3]
VAR Y_POSITION = [Y|C|Y|1.3]
VAR Z_POSITION = [Z|C|Z|1.3]
VAR ARC_CENTRE_I_INC_POSITION = [I|A|I|1.3]
VAR ARC_CENTRE_J_INC_POSITION = [J|A|J|1.3]
VAR X_HOME_POSITION = [XH|A|X|1.3]
VAR Y_HOME_POSITION = [YH|A|Y|1.3]
VAR Z_HOME_POSITION = [ZH|A|Z|1.3]
VAR SAFE_Z_HEIGHT = [SAFEZ|A|Z|1.3]
VAR DWELL_TIME = [DWELL|A|P|1.2]
+================================================
+
+    Block definitions for toolpath output
+
+================================================

+---------------------------------------------------
+  Commands output at the start of the file
+---------------------------------------------------

begin HEADER
"%"
" G00 G21 G40 G49"
" G17 G80 G90 G94 G99"
" G64 P0.1 R5 S90 D0.01"
" ( Program: [TP_FILENAME][TP_EXT] )"
" (-------------- Vectric --------------)"
" (  Stock Dimensions )"
" (  X Length = [XLENGTH] )"
" (  Y Length  = [YLENGTH] )"
" (  Z Height   = [ZLENGTH] )"
" (--------------------------------------)"
" (   Zero Position )"
" (  X Min = [XMIN]    X Max = [XMAX] )"
" (  Y MIN = [YMIN]    Y Max = [YMAX] )"
" (  Z Min = [ZMIN]    Z Max = [ZMAX] )"
" (--------------------------------------)"
" (   Workpiece Home Position )"
" (  X = [XH] Y = [YH] Z = [ZH] )"
" (  Safe Height  )"
" (  Z = [SAFEZ] )"
" (--------------------------------------)"
" (        PP Output for EdingCNC       )"
" (    -- Tool change: --    )"
" ( Toolpath:      [TOOLPATH_NAME] )"
" ( Tool Name:     [TOOLNAME] )"
" ( Tool Number:   T[T] )"
" ( Feedrate:         [FC] mm/min )"
" ( Plunge Rate: [FP] mm/min )"
" ( Spindle Speed:  [S] U/min )"
" G00 G53 Z0"
" Msg[34] Please insert Tool T[T] [TOOLNAME] [34] "
" T[T] M06"
" G43 H[T]"
" Msg[34] Please insert Tool T[T] [TOOLNAME] [34] "
" [S] M03"
" Msg[34] Toolpath: [TOOLPATH_NAME] [34] "
" Msg[34] Tool Name: [TOOLNAME] [34] "
" Msg[34] Tool Number: T[T] [34] "
" G00 [XH] [YH]"
" G00 [ZH]"
" M07"
+---------------------------------------------------
+  Command output for Tool Change
+---------------------------------------------------

begin TOOLCHANGE
" (    -- Tool Change: --    )"
" ( Toolpath:         [TOOLPATH_NAME] )"
" ( Tool Name:        [TOOLNAME] )"
" ( Tool Number:      T[T] )"
" ( Feedrate:            [FC] mm/min )"
" ( Plunge Rate.:    [FP] mm/min )"
" ( Spindle Speed:     [S] U/min )"
" ( Previous Tool: T[TP] )"
" Msg[34] Please insert Tool T[T] [TOOLNAME] [34] "
" T[T] M06"
" G43 H[T]"
" Msg[34] Please insert Tool T[T] [TOOLNAME] [34] "
" [S] M03"
" Msg[34] Toolpath: [TOOLPATH_NAME] [34] "
" Msg[34] Tool Name: [TOOLNAME] [34] "
" Msg[34] Tool Number: T[T] [34] "
" G00 [XH] [YH]"
" G00 [ZH]"
" M07"


+---------------------------------------------------
+  Commands output for rapid moves
+---------------------------------------------------

begin RAPID_MOVE

" G00 [X] [Y] [Z]"


+---------------------------------------------------
+  Commands output for the first feed rate move
+---------------------------------------------------

begin FIRST_FEED_MOVE

" G01 [X] [Y] [Z] [F]"


+---------------------------------------------------
+  Commands output for feed rate moves
+---------------------------------------------------

begin FEED_MOVE

" G01 [X] [Y] [Z]"

+---------------------------------------------------
+  Commands output for the first clockwise arc move
+---------------------------------------------------

begin FIRST_CW_ARC_MOVE

" G02 [X] [Y] [I] [J] [F]"

+---------------------------------------------------
+  Commands output for clockwise arc  move
+---------------------------------------------------

begin CW_ARC_MOVE

" G02 [X] [Y] [I] [J]"

+---------------------------------------------------
+  Commands output for the first counterclockwise arc move
+---------------------------------------------------

begin FIRST_CCW_ARC_MOVE

" G03 [X] [Y] [I] [J] [F]"

+---------------------------------------------------
+  Commands output for counterclockwise arc move
+---------------------------------------------------

begin CCW_ARC_MOVE

" G03 [X] [Y] [I] [J]"

+---------------------------------------------------
+  Commands output for the first clockwise helical arc move
+---------------------------------------------------------
begin FIRST_CW_HELICAL_ARC_MOVE

" G02 [X] [Y] [I] [J] [Z] [F]"

+---------------------------------------------------------
+  Commands output for clockwise helical arc move
+---------------------------------------------------------
begin CW_HELICAL_ARC_MOVE

" G02 [X] [Y] [I] [J] [Z]"

+---------------------------------------------------------------
+  Commands output for the first counter-clockwise helical arc move
+---------------------------------------------------------------
begin FIRST_CCW_HELICAL_ARC_MOVE

" G03 [X] [Y] [I] [J] [Z] [F]"

+---------------------------------------------------------------
+  Commands output for counter-clockwise helical arc move
+---------------------------------------------------------------
begin CCW_HELICAL_ARC_MOVE

" G03 [X] [Y] [I] [J] [Z]"

+--------------------------------------------------------------------
+  Commands output for the first clockwise helical arc plunge move
+--------------------------------------------------------------------
begin FIRST_CW_HELICAL_ARC_PLUNGE_MOVE

" G02 [X] [Y] [I] [J] [Z] [F]"

+--------------------------------------------------------------------
+  Commands output for clockwise helical arc plunge move
+--------------------------------------------------------------------
begin CW_HELICAL_ARC_PLUNGE_MOVE

" G02 [X] [Y] [I] [J] [Z]"

+--------------------------------------------------------------------------
+  Commands output for the first counter-clockwise helical arc plunge move
+--------------------------------------------------------------------------
begin FIRST_CCW_HELICAL_ARC_PLUNGE_MOVE

" G03 [X] [Y] [I] [J] [Z] [F]"

+--------------------------------------------------------------------------
+  Commands output for counter-clockwise helical arc plunge move
+--------------------------------------------------------------------------
begin CCW_HELICAL_ARC_PLUNGE_MOVE

" G03 [X] [Y] [I] [J] [Z]"

+----------------------------------------------------------
+  Output for new segment - Toolpath with same tool and different spindle speed
+---------------------------------------------------

begin NEW_SEGMENT

" ( Spindle Speed:     [S] RPM )"
" [S] M03"
" Msg[34] Toolpath: [TOOLPATH_NAME] [34] "

+----------------------------------------------------
+  Output for all dwell times
+----------------------------------------------------

begin DWELL_MOVE

"G04 [DWELL]"

+---------------------------------------------------
+  Commands output at the end of the file
+---------------------------------------------------

begin FOOTER

" ( Go to Starting Position )"
" G00 G40 [ZH]"
" G00 [XH] [YH]"
" M05 M09"
" Msg[34] Going to Machine Home [34] "
" G28 ( Move to Machine Home )"
" Msg[34] Machine Home reached [34] "
" M30 ( Program End )"
"%"
