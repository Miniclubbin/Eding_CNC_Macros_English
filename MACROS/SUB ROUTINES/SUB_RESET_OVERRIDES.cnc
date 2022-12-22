sub RESET_OVERRIDES

;M50 P.. Set feed Override to given P value, if P value is less than zero feed override is disabled and the value remains as is.
;M51 P.. Set speed Override to given P value, if P value is less than zero speed override is switched off.

M50 P100 ; reset feed override to 100%
M51 P100 ; reset speed override to 100%
msg "Overrides Reset"

endsub
