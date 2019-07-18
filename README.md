
NOTE: This documentation is a work in progress. More formal and detailed documnetation will be added in the coming months. For now we include just quick startup notes:

1. To get Homer3 started in Matlab:

Open Matlab and in the command window, change the current folder to the Homer3 root folder that you downloaded. 

In Matlab command window, type

   >> setpaths

This will set all the required matlab search paths for Homer3. Note: this step should be done every time a new Matlab session is started. 

At this point you should be ready to start Homer3 from the Matlab command window.

2. Run the demo demo_snirf.m (which should be available on the Matlab command line after running setpaths). It demonstrates how to use 
SnirfClass reader/writer to save and load SNIRF files. The Homer3 project includes sample .nirs files (DataTree/AcquiredData/Snirf/Examples) 
which the demo converts to .snirf files and then shows how to load them back into memory. 

