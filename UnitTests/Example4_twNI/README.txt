The Example4_twNI groupResults_homer2_lpf_*.mat output files were generated on Mar 4, 2018, using Homer2_UI v2.8.7. 
The processing stream in processOpt_default_homer2.cfg was used with 4 different lpf values for hmrBandpassFilter

    lpf=0.30  ==> groupResults_homer2_lpf_0_30.mat
    lpf=0.50  ==> groupResults_homer2_lpf_0_50.mat
    lpf=0.70  ==> groupResults_homer2_lpf_0_70.mat
    lpf=1.00  ==> groupResults_homer2_lpf_1_00.mat

The following procedure was used to generate this output:

1) cd <homer2_root_folder>/homer2; 
2) setpaths('rmpathconfl');
3) cd <homer2_root_folder>/homer3/UnitTests/Example4_twNI/
4) resetGroupFolder; clear all; clear classes; close all force; fclose all;
5) start Homer2_UI 
6) When Homer2_UI starts it will ask you to choose a processing options config file. Select
   processOpt_default_homer2.cfg.
7) Go to the Group Average panel and change the value in the edit box labeled 
   'Grp Avg Pass Thresh (Hb x 1e-6)' to 50.
8) Click 'Options' button and change lpf value for hmrBandpassFilter to .7 (or whichever 
   groupResults_homer2_lpf_*.mat you want to generate) 
9) Under Calculate click Group popup menu item. this will generate groupResults.mat. 
10) Copy groupResults.mat to the groupResults_homer2_lpf_*.mat file corresponding 
    to the lpf value you used. 

