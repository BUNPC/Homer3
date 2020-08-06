classdef bpGoodQuality < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ChannelselectionUIFigure  matlab.ui.Figure
        barPlot                   matlab.ui.control.UIAxes
        ThresholdSliderLabel      matlab.ui.control.Label
        ThresholdSlider           matlab.ui.control.Slider
        SaveButton                matlab.ui.control.Button
    end

    
    properties (Access = private)
        qMats % Quality matrices from NIRSPlot quality computation
        qThld % Threshold for marking good-quality channels
        good_combo_link % Channels' normalized quality array (#chan x 1)
        bp %boxplot
        thldLn % threshold line
        idxBadCh  % Indices of channels below the quality threhold
        idxGoodCh % Indices of channels above the quality threhold
        parentFigure % The parent figure handle
        nirsplot_param % nirsplot parameters from the parent Figure
        %raw % content of .fnirs raw file
%        rawFname % filename of the .fnirs file
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, hFigure)
            app.parentFigure = hFigure;
            app.nirsplot_param = getappdata(app.parentFigure,'nirsplot_parameters');
            app.good_combo_link = app.nirsplot_param.quality_matrices.good_combo_link;
            app.qThld = app.nirsplot_param.quality_threshold;         
            app.bp = bar(app.barPlot,app.good_combo_link,'Horizontal','on');
            app.barPlot.YDir = 'reverse';          
            app.bp.FaceColor = 'flat';
            app.barPlot.Box = 'on';
            app.barPlot.YLabel.String  = 'Channel';
            app.barPlot.XLim = [0,1];
            %app.barPlot.YTick = round(linspace(1,size(app.good_combo_link,1),5));
            app.barPlot.YTick = 1:2:size(app.good_combo_link,1);
            %app.barPlot.YTickLabel = flipud(app.barPlot.YTickLabel);
            app.thldLn = xline(app.barPlot,app.qThld,'--r');
            app.ThresholdSlider.Value = round(app.qThld*100);
            app.idxBadCh = app.good_combo_link<app.qThld;
            app.idxGoodCh = ~app.idxBadCh;
            app.bp.CData(app.idxBadCh,:) = repmat([0.6, 0.6, 0.6],sum(app.idxBadCh),1);
            app.bp.CData(app.idxGoodCh,:) = repmat([0 1 0],sum(app.idxGoodCh),1);
            % For future changes:
            %app.bp.DataTipTemplate.DataTipRows(1).Label = 'Quality';
            %app.bp.DataTipTemplate.DataTipRows(2).Label = 'Channel';
        end

        % Value changing function: ThresholdSlider
        function ThresholdSliderValueChanging(app, event)
            app.qThld  = (event.Value)/100;
            app.thldLn.Value = app.qThld;
            app.idxBadCh = app.good_combo_link<app.qThld;
            app.idxGoodCh = ~app.idxBadCh;
            app.bp.CData(app.idxBadCh,:) = repmat([0.6, 0.6, 0.6],sum(app.idxBadCh),1);
            app.bp.CData(app.idxGoodCh,:) = repmat([0 1 0],sum(app.idxGoodCh),1);
            
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            app.nirsplot_param.quality_matrices.active_channels = app.idxGoodCh;
            app.qThld = round(app.qThld,2);  
            app.nirsplot_param.quality_threshold = app.qThld;
            setappdata(app.parentFigure,'nirsplot_parameters',app.nirsplot_param);
            uiresume(app.parentFigure);  
            msgbox(['You are requiring above of ',num2str(app.qThld*100),'% of quality'],'Info');
            delete(app.ChannelselectionUIFigure);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create ChannelselectionUIFigure and hide until all components are created
            app.ChannelselectionUIFigure = uifigure('Visible', 'off');
            app.ChannelselectionUIFigure.Position = [100 100 532 381];
            app.ChannelselectionUIFigure.Name = 'Channel selection';

            % Create barPlot
            app.barPlot = uiaxes(app.ChannelselectionUIFigure);
            title(app.barPlot, 'Good-quality Channels')
            xlabel(app.barPlot, 'Quality')
            ylabel(app.barPlot, '# Channel')
            app.barPlot.Position = [120 42 402 319];

            % Create ThresholdSliderLabel
            app.ThresholdSliderLabel = uilabel(app.ChannelselectionUIFigure);
            app.ThresholdSliderLabel.HorizontalAlignment = 'right';
            app.ThresholdSliderLabel.Position = [16 14 59 22];
            app.ThresholdSliderLabel.Text = 'Threshold';

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.ChannelselectionUIFigure);
            app.ThresholdSlider.MajorTicks = [0 10 20 30 40 50 60 70 80 90 100];
            app.ThresholdSlider.Orientation = 'vertical';
            app.ThresholdSlider.ValueChangingFcn = createCallbackFcn(app, @ThresholdSliderValueChanging, true);
            app.ThresholdSlider.Position = [44 58 3 303];

            % Create SaveButton
            app.SaveButton = uibutton(app.ChannelselectionUIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [425 14 83 22];
            app.SaveButton.Text = 'Save';

            % Show the figure after all components are created
            app.ChannelselectionUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = bpGoodQuality(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ChannelselectionUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            uiresume(app.parentFigure);  
            % Delete UIFigure when app is deleted
            delete(app.ChannelselectionUIFigure)
        end
    end
end