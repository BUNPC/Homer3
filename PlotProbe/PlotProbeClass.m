classdef PlotProbeClass < handle
    
    properties
        name;
        y;
        tHRF;
        SD;
        ch;
        axScl;
        plotname;
        tMarkInt;
        tMarkAmp;
        tMarkShow;
        hidMeasShow;
        condition;
        active;
        objs;
    end
    
    methods
        
        % --------------------------------------------------------------
        function obj = PlotProbeClass(handles)
            obj.name = 'plotprobe';
            obj.y = [];
            obj.tHRF = [];
            obj.SD = [];
            obj.ch = [];
            obj.axScl = [1,1];
            obj.plotname = '';
            obj.tMarkInt = 5;
            obj.tMarkAmp = 0;
            obj.tMarkShow = 0;
            obj.hidMeasShow = 0;
            
            if exist('handles','var')
                obj.active = get(handles.checkboxPlotProbe, 'value');
            else
                obj.active = 0;
            end
            
            obj.objs.Data.h = [];
            obj.objs.Data.pos = [];
            
            obj.objs.CtrlPanel.h = [];
            obj.objs.CtrlPanel.pos    = [0.00, 0.00, 1.00, 0.22];
            
            obj.objs.TmarkPanel.h = [];
            obj.objs.TmarkPanel.pos   = [0.20, 0.00, 0.30, 1.00];
            
            obj.objs.SclPanel.h = [];
            obj.objs.SclPanel.pos     = [0.00, 0.00, 0.20, 1.00];
            
            obj.objs.BttnDup.h = [];
            obj.objs.BttnDup.pos      = [0.52, 0.54, 0.15, 0.25];
            
            obj.objs.BttnHidMeas.h = [];
            obj.objs.BttnHidMeas.pos  = [0.52, 0.14, 0.30, 0.25];
            
            scrsz = get(0,'ScreenSize');
            rdfx = 2.2;
            rdfy = rdfx-.5;
            obj.objs.Figure.h = [];
            obj.objs.Figure.pos = [1, scrsz(4)/2-scrsz(4)*.2, scrsz(3)/rdfx, scrsz(4)/rdfy];
        end
        

        % --------------------------------------------------------------
        function delete(obj)
            if ishandle(obj.objs.Figure.h)
                delete(obj.objs.Figure.h);
            end
        end
        
        % --------------------------------------------------------------
        function Reset(obj)
            obj.axScl = [1,1];
            obj.plotname = '';
            obj.tMarkInt = 5;
            obj.tMarkAmp = 0;
            obj.tMarkShow = 0;
            obj.hidMeasShow = 0;
            obj.active = 0;
            
            obj.objs.Data.h = [];
            obj.objs.Data.pos = [];
            
            obj.objs.CtrlPanel.h = [];
            obj.objs.CtrlPanel.pos    = [0.00, 0.00, 1.00, 0.22];
            
            obj.objs.TmarkPanel.h = [];
            obj.objs.TmarkPanel.pos   = [0.20, 0.00, 0.30, 1.00];
            
            obj.objs.SclPanel.h = [];
            obj.objs.SclPanel.pos     = [0.00, 0.00, 0.20, 1.00];
            
            obj.objs.BttnDup.h = [];
            obj.objs.BttnDup.pos      = [0.52, 0.54, 0.15, 0.25];
            
            obj.objs.BttnHidMeas.h = [];
            obj.objs.BttnHidMeas.pos  = [0.52, 0.14, 0.30, 0.25];
            
            scrsz = get(0,'ScreenSize');
            rdfx = 2.2;
            rdfy = rdfx-.5;
            obj.objs.Figure.h = [];
            obj.objs.Figure.pos = [1, scrsz(4)/2-scrsz(4)*.2, scrsz(3)/rdfx, scrsz(4)/rdfy];
        end

    end
    
end