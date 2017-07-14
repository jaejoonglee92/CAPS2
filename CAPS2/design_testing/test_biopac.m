io32dir = 'C:\Program Files\MATLAB\R2012b\toolbox\io32';
trigger_biopac = biopac_setting(io32dir);
BIOPAC_PULSE_WIDTH = 1;
feval(trigger_biopac,BIOPAC_PULSE_WIDTH);


