
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


Downloading Homer3:
===================
To download go to [Homer3 home page](https://github.com/BUNPC/Homer3) and click the green "Clone or download" button on right. Then click "Download ZIP" right below the green button. Once you have downloaded the zip file, unzip it. 

In addition to this if you do NOT have Matlab installed on your computer you will want to be able to run the executable that is included in the project. To do this follow this additional step:

### Windows:


Download and install the 64-bit MATLAB Runtime R2017b (9.3) for Windows from the [Mathworks website](https://www.mathworks.com/products/compiler/matlab-runtime.html). 

### Mac:

Download and install the 64-bit MATLAB Runtime R2017b (9.3) for Mac from the [Mathworks website](https://www.mathworks.com/products/compiler/matlab-runtime.html)  



Installing and running Homer3 if you do NOT have Matlab:
--------------------------------------------------------

Windows:

* In File Browser (or Windows Explorer in older Windows versions) navigate to the homer3 root folder you have just downloaded and unzipped. 
* Go into the Install folder and find and unzip the file homer3_install_win.zip. Please make sure that the unzipped folder is called homer3_install?. If this folder already existed because of an older version, then you must rename that folder before unzipping this new install file.
* Go into the newly created homer3_install folder and double click on the file setup.bat. This should start the installation process. When it finishes you should see a Homer3 icon on your Desktop.
* You can now execute Homer3 by double clicking the Homer3 icon on the desktop.


Mac:

* In Finder navigate to the homer3 root folder you have just downloaded and unzipped. 
* Go into the Install folder and find and unzip the file homer3_install_mac.zip. Please make sure that the unzipped folder is called homer3_install?. If this folder already existed because of an older version, then you must rename that folder before unzipping this new install file.
* Go into the newly created homer3_install folder and double click on the file setup.command. This should start the installation process. When it finishes you should see a Homer3.command icon on your Desktop along with a link to a sample data folder called 'SubjDataSample'.
* You can now execute Homer3 by double clicking the Homer3.command icon on the desktop.

For either Mac or Windows Homer3 it will open by default in the sample subject folder that came with the installation. You will be asked to choose a processing options config file. Select the only one available, test_process.cfg. Once selected Homer3 should open the test.snirf data file. You are now ready to use Homer3 to work with this data. 


Installing and running Homer3 if you have Matlab:
-------------------------------------------------

__A)__ Open Matlab and in the command window, change the current folder to the Homer3 root folder that you downloaded. In the command window, type

<pre> 
	>> setpaths
</pre>

This will set all the required matlab search paths for Homer3. Note: this step should be done every time a new Matlab session is started. 

At this point you should be ready to start Homer3 from the Matlab command window. 

To run:

* Type Homer3 in the command window

* Navigate to a subject folder and select to open it. 

* Homer3 will ask you to choose a processing options config file. If you do not have one to select, click the CANCEL button and a default config file will be generated for you. 


__B)__ Running the SNIRF demo:

Run the demos demo_snirf.m and demo_snirf_readfile.m (which should be available on the Matlab command line after running setpaths). They demonstrate how to use SnirfClass reader/writer to save, load and read SNIRF files. Make sure to run demo_snirf before demo_snirf_readfile.m since it expects the snirf files generated by demo_snirf to be present (otherwises it displays a message box stating this if it doesn't find them). 

The Homer3 project includes sample .nirs files (DataTree/AcquiredData/Snirf/Examples) which the demo converts to .snirf files and then shows how to load them back into memory. 

After generating the 3 example .snirf files with demo_snirf, run the demo which shows how to load and display data from a .snirf file. Type 

<pre>
	>> help demo_snirf_readfile
</pre>

Or simply 

<pre>
	>> snirf = demo_snirf_readfile('Simple_Probe.snirf');
	>> snirf = demo_snirf_readfile('FingerTapping_run3_tdmlproc.snirf');
	>> snirf = demo_snirf_readfile('neuro_run01.snirf');
</pre>

