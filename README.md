
NOTE: This documentation is a work in progress. More detailed documentation will be added in the coming months/years.


Introduction:
=============
Homer3 is a Matlab application used for analyzing fNIRS data to obtain estimates and maps of brain activation. It is a continuation of the work on the well-established HOMER2 software which itself evolved since the early 1990s, first as the Photon Migration Imaging toolbox, then HOMER, and now HOMER2. While it's purpose, functionality and graphical user interface (GUI) are similar to those applications it adds several important advancements and features:  

1) Homer3 has explicit and more sophisticated support for group and subject-level analyses. While HOMER2 has some group and subject-level analysis support it is limited to fixed functions, built into core HOMER2 code. Homer3 on the other hand has flexible and configurable group and subject-level analysis support using the same mechanism as the configurable run-level analysis. Each processing level, group, subject, and run has it's own processing stream to which the user can add their own algorithms.  

2) Adding functions to the processing stream does NOT require code changes to the core Homer3 code; it does in HOMER2. All that's required  to integrate a user function into one of 3 processing streams is add the file containing it to the Homer3 folder FuncRegistry/UserFunctions and add a help section in the file that can be interpreted correctly by the Homer3 ProcStreamClass parser.

3) Ability to read/write the SNIRF file format (see https://github.com/fNIRS/snirf) - a universal file format for storing and sharing NIRS data independently of any specific application-specific file format such as Matlab. HOMER2 uses the Matlab file format to store NIRS data. Homer3 provides the SnirfClass object which reads and writes .snirf files. In addition it provides a NirsClass object which is able to read/write the HOMER2-style .nirs files and convert group folders consisting of .nirs files to the equivalent .snirf files. The modular/object-oriented design of Homer3 (see point 5) allows reader/writers of other formats to be easily added and exported to .snirf format. For now the only other format it can load and convert from is .nirs but others will be added in the future.  

4) Ability to sub-divide data from one acquisition file by channels into independent data blocks and then independently process them. The HRF averages from different data blocks can then be viewed by clicking on the corresponding probe channels.

5) Homer3 does not change the original files that it uses for it's analysis and clearly separates data into acquired (from original data files) and derived (any processed data). All processed data is stored in a separate groupResults.mat file (later we will add the ability to export the processed data to the SNIRF and other file formats as well). This allows users to be confident in the integrity of the original data files. 

6) Clearer, simpler GUI interface. Again, even though much of the graphics are based on HOMER2, it is cleaner and simpler. So for example the probe display in the "MainGUI", distinguishes between sources and detectors by color (red => source), (blue => detector) rather than by letters vs numbers as is done in HOMER2. In addition, there are fewer controls and the controls that are there are grouped into panels by function.  

7) Homer3 uses a simple and understandable object-oriented software design which allows it to be more easily modified, extended and maintained. Briefly, the Homer3 application consists of 5 independent GUIs: "MainGUI" (not named that yet but is the Homer3 GUI itself), StimEditGUI, PlotProbeGUI, ProcStreamEditGUI, and ProcStreamOptionsGUI. These GUIs load and operate on the applications two main and independent data structures: DataTree and FuncRegistry. 

DataTree is the data structure containing (a) all the acquired data loaded in a group folder from the original data files, (b) any processed data derived from running the processing stream analysis, loaded from groupResults.mat and (c) processing stream specifying the chain of user functions to execute to generate the processed data for each processing element in the DataTree. 

FuncRegistry is the data structure containing the list of ALL user functions available to the user for the purpose of constructing/modifying a group, subject or run-level processing stream. 

Typically the four GUIs StimEditGUI, PlotProbeGUI, ProcStreamEditGUI, and ProcStreamOptionsGUI will be started from the "MainGUI".
But any one of the 5 GUIs can be run separately and all do essentially the same thing at start up; load the data files in a group folder and the list of user function into the two main data structures, DataTree and FuncRegistry. They then display and/or edit these two data structures in various ways depending on the purpose of the particular GUI. 


Installing and Running Homer3:
==============================

1. To get Homer3 started in Matlab:

Open Matlab and in the command window, change the current folder to the Homer3 root folder that you downloaded. 

In Matlab command window, type

   >> setpaths

This will set all the required matlab search paths for Homer3. Note: this step should be done every time a new Matlab session is started. 

At this point you should be ready to start Homer3 from the Matlab command window.

2. Run the demos demo_snirf.m and demo_snirf_readfile.m (which should be available on the Matlab command line after running setpaths). They demonstrate how to use SnirfClass reader/writer to save, load and read SNIRF files. Make sure to run demo_snirf before demo_snirf_readfile.m since it expects the snirf files generated by demo_snirf to be present (otherwises it displays a message box stating this if it doesn't find them). 

The Homer3 project includes sample .nirs files (DataTree/AcquiredData/Snirf/Examples) which the demo converts to .snirf files and then shows how to load them back into memory. 

