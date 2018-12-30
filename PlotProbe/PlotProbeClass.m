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
        handles;
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

            obj.handles = struct( ...
                'Figure',[], ...
                'FigureDup',[], ...
                'Data',[], ...
                'CtrlPanel',[], ...
                'TmarkPanel',[], ...
                'SclPanel',[], ...
                'BttnDup',[], ...
                'BttnHidMeas', [] ...
                );
            
        end
        

        % --------------------------------------------------------------
        function delete(obj)
            if ishandle(obj.handles.Figure)
                delete(obj.handles.Figure);
            end
            if ishandle(obj.handles.FigureDup)
                delete(obj.handles.FigureDup);
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
            
            obj.handles.Data = [];
            obj.handles.CtrlPanel = [];
            obj.handles.TmarkPanel = [];
            obj.handles.SclPanel = [];
            obj.handles.BttnDup = [];
            obj.handles.BttnHidMeas = [];
            obj.handles.Figure = [];
            obj.handles.FigureDup = [];
        end
        
        
        % --------------------------------------------------------------
        function Display(obj, y, tHRF, SD, ch, tMarkUnits)
            if ~obj.active
                obj.handles.Figure = [];
                obj.handles.FigureDup = [];
                return;
            end
            
            if ishandles(obj.handles.Figure)
                figure(obj.handles.Figure);
            else
                obj.handles.Figure = PlotProbeGUI();
                xlim([0,1]);
                ylim([0,1]);
            end
            
            hData = plotProbe( y, tHRF, SD, ch, [], obj.axScl, obj.tMarkInt, obj.tMarkAmp );
            
            % Modify and add graphics objects in plot probe figure
            obj.handles.CtrlPanel    = findobj(obj.handles.Figure, 'tag','uipanelControl');
            obj.handles.SclPanel     = findobj(obj.handles.Figure, 'tag','uipanelScaling');
            obj.handles.TmarkPanel   = findobj(obj.handles.Figure, 'tag','uipanelTimeMarks');
            obj.handles.BttnDup      = findobj(obj.handles.Figure, 'tag','pushbuttonPlotProbeDuplicate');
            obj.handles.BttnHidMeas  = findobj(obj.handles.Figure, 'tag','radiobuttonPlotProbeShowHiddenMeas');
            showHiddenObjs( 2*obj.hidMeasShow+obj.tMarkShow, ch, y, hData );
                        
        end
        
        
        % --------------------------------------------------------------
        function SetTmarkAmp(obj, tMarkAmp)
            obj.tMarkAmp = tMarkAmp;
        end
        
        
        % --------------------------------------------------------------
        function tMarkAmp = GetTmarkAmp(obj)
            h = findobj(obj.handles.Figure, 'tag','editPlotProbeTimeMarkersAmp');
            tMarkAmp = str2double(get(h,'string'));
        end

        
        % --------------------------------------------------------------
        function CloseGUI(obj)
            if ishandle(obj.handles.Figure)
                delete(obj.handles.Figure);
            end
            if ishandle(obj.handles.FigureDup)
                delete(obj.handles.FigureDup);
            end
            obj.handles.Figure = [];
            obj.handles.FigureDup = [];            
        end
        
    end
    
end


