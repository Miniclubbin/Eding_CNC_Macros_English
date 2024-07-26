+=======================================================
+
+ Vectric machine output configuration file
+ Post-Processor for Vectric after Version 9.5
+ Post-Processor for EdingCNC(V5)
+
+=======================================================
+
+ History
+
+ Author        DD/MM/YYYY   Changes
+ ========      ===========  ================================
+ DJ-Bino       23/12/2013   PP written

+ MiniClubbin   19/12/2022   Translated to English, trimmed "new segment" lines to speed up gcode
+ MiniClubbin   21/12/2022   REMOVED G54 from HEADER block to allow for multiple work offsets
+ MiniClubbin   21/12/2022   Commented out M07 commands
+ MiniClubbin   27/12/2022   Adjusted footer: reordered M5/M9, commented out G28
+ MiniClubbin   17/06/2022   Uncommented G28, M07, added MCSZ0 in footer
+ MiniClubbin   17/07/2023   Removed "Zero Position" block from header
+ MiniClubbin   17/08/2023   Added subroutine reference for auto probing CUTOUT
+ MiniClubbin   17/08/2023   Removed G43 Hxx from tool change
+ MiniClubbin   21/09/2023   Added M08 to programs to start chiller for spindle
+ MiniClubbin   12/2023     Eding V5 revamp - Removed material comments from header, added log messages
+ MiniClubbin   07/2024     SIMPLIFIED: REMOVED MACRO CALLOUTS FROM HEADER, COMMENTED OUT G28 IN FOOTER
+=======================================================

POST_NAME = "EDINGCNC (*.nc)"

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
" ( First Tool [T]: [TOOLNAME] ) "

"%"
" LogMsg %d [34] TIME-Program: [TP_FILENAME] Started[34] "
" G00 G21 G40 "
" G17 G80 G90 G94 G99 "
" G64 P0.1 R6 S100 D0.002 "
" (  Safe Height  )"
" (  Z = [SAFEZ] )"
" (--------------------------------------)"
" (    -- Tool change: --    )"
" ( Toolpath:      [TOOLPATH_NAME] )"
" ( Tool [T]:      [TOOLNAME] )"
" ( Feedrate:      [FC] mm/min )"
" ( Plunge Rate:   [FP] mm/min )"
" ( Spindle Speed: [S] RPM )"

" G00 G53 Z0"
" Msg[34] ***INSERT TOOL T[T] [TOOLNAME] [34] "
" T[T] M06"
" LogMsg %d [34] TOOLCHANGE-Program: [TP_FILENAME] Tool [T] [TOOLNAME][34] "
" M08"
" [S] M03"
" Msg[34] T[T]: [TOOLNAME] [34] "
" Msg[34] Toolpath: [TOOLPATH_NAME] [34] "
" Msg[34] Time: [34] %d "

" M07"
" G00 [XH] [YH]"
" G00 [ZH]"

+---------------------------------------------------
+  Command output for Tool Change
+---------------------------------------------------

begin TOOLCHANGE
" (    -- Tool Change: --    )"
" ( Toolpath:      [TOOLPATH_NAME] )"
" ( Tool [T]:      [TOOLNAME] )"
" ( Feedrate:      [FC] mm/min )"
" ( Plunge Rate.:  [FP] mm/min )"
" ( Spindle Speed: [S] RPM )"
" ( Previous Tool: T[TP] )"
" Msg[34] ***INSERT TOOL T[T] [TOOLNAME] [34] "
" T[T] M06"
" LogMsg %d [34] TOOLCHANGE-Program: [TP_FILENAME] Changed Tool [T] [TOOLNAME][34] "
" (insert macros here) "
" M08"
" [S] M03"
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
" M08"
" [S] M03"
" Msg[34] T[T]: [TOOLNAME] [34] "
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

" Msg[34] Job Complete [34] "
" G53 G0 z0 (Raise Z MCS0)"
" M05 M09 (Shutdown spindle/coolant)"
" (G28) ( Move to Machine Home )"
" LogMsg %d [34] TIME-Program: [TP_FILENAME] Finished [34] "
" M30 "
"%"
