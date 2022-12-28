# Overview
Macros and other specific files to customize Eding CNC.

## First of all, major credit to Sorotec for creating the original macro file and serving as the basis for this undertaking!

These macros were derived from Sorotec macro.cnc V2.1e without ATC. I have translated the comments to english, changed the naming convention for sub routines, and re-ordered the user macros to better suit my operations. See the changelog at the top of the macro file for more information. Sorry if it's not exact, it has been a long time working on this!

If you want to use these files, simply copy the files into your Eding CNC folder on the C: drive:
  - Rename the macro files to "macro.cnc" and "user_macro.cnc" and place in your "C:\CNC4.03\" directory
  - Drag the icon files into your "C:\CNC4.03\icons\op_f_key\user\" directory
  - Drag the dialog pictures files into your "C:\CNC4.03\dialogPictures\" directory
  - Save the post processor file and add to Vectric software through their dialog

I currently use this with a Sorotec Compact Line 1007 with Mafell 1000w quick tool change router and Sorotec tool length sensor. I program CAD/CAM using Vectric VCarve and include manual tool changes in the post processor. 

With my current macro.cnc file, a tool change M6 command will:
- pause a running job
- move to tool change position
- wait for confirmation of tool change
- measure tool length
- continue job

# MACROS Folder
This folder contains a few items:
- Default Eding CNC macro.cnc to use as a guide/template
- Spindle PWM compensation table for Mafell FM1000 PV-WS 230V/50 Hz router
- Latest macro files
  - Rename the file to "macro.cnc" and "user_macro.cnc" and place in your "CNC4.03" directory on the C: drive

# ICONS Folder
- Latest user button icons for the latest macro.cnc file. 
- Latest dialogpictures folder containing updated png files and naming for the latest macro.cnc file

# POST PROCESSOR Folder
This folder contains the latest Post Processor for Vectric software.
