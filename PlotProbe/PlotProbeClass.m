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
        
        
        % --------------------------------------------------------------
        function Display(obj, y, tHRF, SD, ch, tMarkUnits)
            if ~obj.active
                if ishandles(obj.objs.Figure.h)
                    delete(obj.objs.Figure.h);
                end
                obj.objs.Figure.h = [];
                return;
            end
            
            if ishandles(obj.objs.Figure.h)
                figure(obj.objs.Figure.h);
            else
                obj.objs.Figure.h = figure;
                
                % Set figure toolbar to always appear - by default
                % it's set to 'auto' which makes it disappear
                % when the zoom is displayed
                set(obj.objs.Figure.h,'toolbar','figure', 'NumberTitle', 'off', 'name','Plot Probe', ...
                    'color',[1 1 1], 'paperpositionmode','auto', 'deletefcn',@DeletePlotProbe);
                p = get(obj.objs.Figure.h,'Position');
                set(obj.objs.Figure.h, 'Position', [p(1)/2, p(2)/2.2,  p(3)*1.3, p(4)*1.3])
                xlim([0,1]);
                ylim([0,1]);
            end
            
            
            hData = plotProbe( y, tHRF, SD, ch, [], obj.axScl, obj.tMarkInt, obj.tMarkAmp );
            
            % Modify and add graphics objects in plot probe figure
            obj.objs.CtrlPanel    = drawPlotProbeControlsPanel( obj.objs.CtrlPanel, obj.objs.Figure.h );
            obj.objs.SclPanel     = drawPlotProbeScale( obj.objs.SclPanel, obj.objs.CtrlPanel.h, obj.axScl, obj.objs.Figure.h);
            obj.objs.BttnDup      = drawPlotProbeDuplicate( obj.objs.BttnDup, obj.objs.CtrlPanel.h, obj.objs.Figure.h );
            obj.objs.BttnHidMeas  = drawPlotProbeHiddenMeas( obj.objs.BttnHidMeas, obj.objs.CtrlPanel.h, obj.hidMeasShow, obj.objs.Figure.h );
            obj.objs.TmarkPanel   = drawPlotProbeTimeMarkers( obj.objs.TmarkPanel, obj.objs.CtrlPanel.h, obj.tMarkInt, obj.tMarkAmp, ...
                                                              obj.tMarkShow, tMarkUnits, obj.objs.Figure.h );
            showHiddenObjs( 2*obj.hidMeasShow+obj.tMarkShow, ch, y, hData );
                        
            % Save the plot probe control panel handles
            obj.y                = y;
            obj.tHRF             = tHRF;
            obj.SD               = SD;
            obj.ch               = ch;
        end
        
        
        % --------------------------------------------------------------
        function SetTmarkAmp(obj, tMarkAmp)
            obj.tMarkAmp = tMarkAmp;
        end
        
        
        % --------------------------------------------------------------
        function tMarkAmp = GetTmarkAmp(obj)
            tMarkAmp = obj.tMarkAmp;
        end

    end
    
end