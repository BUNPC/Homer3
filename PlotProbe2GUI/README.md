# PlotProbe2

### Instructions to run PlotProbe2

1. Open Matlab
2. Go to PlotProbe2 folder on Matlab
3. Add PlotProbe2 to matlab path by running ``` addpath(genpath('.')) ``` command on matlab command window
4. Go to the folder where snirf file is located or use probe.snirf file present in the PlotProbe2 folder
5. Run below commands on matlab command window
``` 
obj = SnirfClass('probe.snirf');
PlotProbe2(obj);
```
6. Note that your filename could be different from ```probe.snirf```, so pass appropriate filename to ```SnirfClass```
