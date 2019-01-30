function lpf = getHomer2LpfValue(isubj, irun)

fname = sprintf('Simple_Probe%d_run0%d.nirs', isubj, irun);
nirs = load(fname, '-mat');
lpf = nirs.procInput.procFunc.funcParamVal{3}{2};


