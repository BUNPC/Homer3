function configSettingsGUI
    global cfgSet
    
    cfgSet = ConfigFileClass();
    
    f = figure('NumberTitle','off');
    f.Name = 'App Setting Config GUI';
    set(f, 'MenuBar', 'none');
    set(f, 'ToolBar', 'none');
    
    param = cell(length(cfgSet.sections),1);
    for i = 1:length(cfgSet.sections)
        param{i} = cfgSet.sections(i).param;
    end
    
    %Number of Parameters
    np = length(cfgSet.sections);
    %Number of Editable Parameters
    n = length(cfgSet.sections) - length(find(cellfun(@isempty,param)));
    
    nAdj = 1;               %Count for Editable Parameters
    p = cell(n,1);          %Panels
    c = cell(n,1);          %Parameters/User Inputs
    
    if n < 11
        if rem(n,2) ~= 0
            p{1} = uipanel('Title',cfgSet.sections(1).name,'FontSize',12,'Position',[0 1-(1/((n+1)/2)) 1 1/((n+1)/2)]);
            if isempty(cfgSet.sections(1).param)
                %Not editable?
                c{1} = uicontrol(p{1}, 'Style', 'text', 'FontSize', 15, 'Units', 'Normalized');
                c{1}.String = 'Not Editable';
                cfgSet.sections(1).val = [];
            elseif isempty(find(strcmp(cfgSet.sections(1).param,cfgSet.sections(1).val),1))
                c{1} = uicontrol(p{1}, 'Style', 'edit', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(1).name);
                c{1}.String = cfgSet.sections(1).val;
                c{1}.Position = [0.125 0.25 0.75 0.5];
                c{nAdj}.Callback = @setVal;
                nAdj = nAdj + 1;
            else
                c{1} = uicontrol(p{1}, 'Style', 'popupmenu', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(1).name);
                c{1}.String = cfgSet.sections(1).param;
                c{1}.Value = find(strcmp(cfgSet.sections(1).param,cfgSet.sections(1).val));
                c{1}.Position = [0.125 0.25 0.75 0.5];
                c{nAdj}.Callback = @setVal;
                nAdj = nAdj + 1;
            end
            if n < 2
                %End
            else
                for i = 2:np
                    if isempty(cfgSet.sections(i).param)
                        %Not editable?
                        continue;
                    elseif isempty(find(strcmp(cfgSet.sections(i).param,cfgSet.sections(i).val),1))
                        p{nAdj} = uipanel('Title',cfgSet.sections(i).name,'FontSize',12,'Position',[0.5*rem(nAdj,2) 1-(floor(nAdj/2)+1)*(1/(n/2+1)) 0.5 1/(n/2+1)]);
                        c{nAdj} = uicontrol(p{nAdj}, 'Style', 'edit', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i).name);
                        c{nAdj}.String = cfgSet.sections(i).val{1};
                        c{nAdj}.Callback = @setVal;
                    else
                        p{nAdj} = uipanel('Title',cfgSet.sections(i).name,'FontSize',12,'Position',[0.5*rem(nAdj,2) 1-(floor(nAdj/2)+1)*(1/(n/2+1)) 0.5 1/(n/2+1)]);
                        c{nAdj} = uicontrol(p{nAdj}, 'Style', 'popupmenu', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i).name);
                        c{nAdj}.String = cfgSet.sections(i).param;
                        c{nAdj}.Callback = @setVal;
                    end
                    c{nAdj}.Value = find(strcmp(cfgSet.sections(i).param,cfgSet.sections(i).val));
                    c{nAdj}.Position = [0.125 0.25 0.75 0.5];
                    nAdj = nAdj + 1;
                end
            end
        else
            if n == 0
                %Nothing
            else
                for i = 0:(np-1)
                    if i == 0
                        if isempty(cfgSet.sections(i+1).param)
                            %Not editable?
                            continue;
                        elseif isempty(find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val),1))
                            p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[0.5*rem(nAdj-1,2) 1-(floor((nAdj-1)/2)+1)*(1/(n/2+1)) 0.5 1/(n/2+1)]);
                            c{nAdj} = uicontrol(p{nAdj}, 'Style', 'edit', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                            c{nAdj}.String = cfgSet.sections(i+1).val{1};
                            c{nAdj}.Callback = @setVal;
                        else
                            p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[0.5*rem(nAdj-1,2) 1-(floor((nAdj-1)/2)+1)*(1/(n/2+1)) 0.5 1/(n/2+1)]);
                            c{nAdj} = uicontrol(p{nAdj}, 'Style', 'popupmenu', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                            c{nAdj}.String = cfgSet.sections(i+1).param;
                            c{nAdj}.Callback = @setVal;
                        end
                        c{nAdj}.Value = find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val));
                        c{nAdj}.Position = [0.125 0.25 0.75 0.5];
                        nAdj = nAdj + 1;
                    else
                        if isempty(cfgSet.sections(i+1).param)
                            %Not editable?
                            continue;
                        elseif isempty(find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val),1))
                            p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[0.5*rem(nAdj-1,2) 1-(floor((nAdj-1)/2)+1)*(1/(n/2+1)) 0.5 1/(n/2+1)]);
                            c{nAdj} = uicontrol(p{nAdj}, 'Style', 'edit', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                            c{nAdj}.String = cfgSet.sections(i+1).val{1};
                            c{nAdj}.Callback = @setVal;
                        else
                            p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[0.5*rem(nAdj-1,2) 1-(floor((nAdj-1)/2)+1)*(1/(n/2+1)) 0.5 1/(n/2+1)]);
                            c{nAdj} = uicontrol(p{nAdj}, 'Style', 'popupmenu', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                            c{nAdj}.String = cfgSet.sections(i+1).param;
                            c{nAdj}.Callback = @setVal;
                        end
                        c{nAdj}.Value = find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val));
                        c{nAdj}.Position = [0.125 0.25 0.75 0.5];
                        nAdj = nAdj + 1;
                    end
                end
            end
        end
    else
        div = ceil(n/5);
        for i = 0:(np-1)
            if i == 0
                if isempty(cfgSet.sections(i+1).param)
                    %Not editable?
                    continue;
                elseif isempty(find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val),1))
                    p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[(1/div)*(rem(nAdj-1,div)) 1-(floor((nAdj-1)/div)+1)*(1/ceil(n/div)) 1/div 1/ceil(n/div)]);
                    c{nAdj} = uicontrol(p{i+1}, 'Style', 'edit', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                    c{nAdj}.String = cfgSet.sections(i+1).val{1};
                    c{nAdj}.Callback = @setVal;
                else
                    p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[(1/div)*(rem(nAdj-1,div)) 1-(floor((nAdj-1)/div)+1)*(1/ceil(n/div)) 1/div 1/ceil(n/div)]);
                    c{nAdj} = uicontrol(p{i+1}, 'Style', 'edit', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                    c{nAdj}.String = cfgSet.sections(i+1).param;
                    c{nAdj}.Callback = @setVal;
                end
                c{nAdj}.Value = find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val));
                c{nAdj}.Position = [0.125 0.25 0.75 0.5];
                nAdj = nAdj + 1;
            else
                p{nAdj} = uipanel('Title',cfgSet.sections(i+1).name,'FontSize',12,'Position',[(1/div)*(rem(nAdj-1,div)) 1-(floor((nAdj-1)/div)+1)*(1/ceil(n/div)) 1/div 1/ceil(n/div)]);
                if isempty(cfgSet.sections(i+1).param)
                    %Not editable?
                    continue;
                elseif isempty(find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val),1))
                    c{nAdj} = uicontrol(p{i+1}, 'Style', 'popupmenu', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                    c{nAdj}.String = cfgSet.sections(i+1).val{1};
                    c{nAdj}.Callback = @setVal;
                else
                    c{nAdj} = uicontrol(p{i+1}, 'Style', 'popupmenu', 'FontSize', 15, 'Units', 'Normalized', 'Tag', cfgSet.sections(i+1).name);
                    c{nAdj}.String = cfgSet.sections(i+1).param;
                    c{nAdj}.Callback = @setVal;
                end
                c{nAdj}.Value = find(strcmp(cfgSet.sections(i+1).param,cfgSet.sections(i+1).val));
                c{nAdj}.Position = [0.125 0.25 0.75 0.5];
                nAdj = nAdj + 1;
            end
        end
    end
    
    if n < 11
        if rem(n,2) ~= 0
            p{nAdj} = uipanel('FontSize',12,'Position',[0 0 1 1/((n+1)/2+1)]);
        else
            p{nAdj} = uipanel('FontSize',12,'Position',[0 0 1 1/(n/2+1)]);
        end
    else
        p{nAdj} = uipanel('FontSize',12,'Position',[0 0 1 1/ceil(n/div)]);
    end
    c{nAdj} = uicontrol(p{nAdj}, 'Style', 'pushbutton', 'FontSize', 15, 'Units', 'Normalized', 'String', 'Save',...
              'Position', [0.125 0.25 0.25 0.5]);
    c{nAdj}.Callback = @cfgSave;
    c{nAdj+1} = uicontrol(p{nAdj}, 'Style', 'pushbutton', 'FontSize', 15, 'Units', 'Normalized', 'String', 'Exit',...
              'Position', [0.625 0.25 0.25 0.5]);
    c{nAdj+1}.Callback = @cfgExit;

%     clear cfgSet
end
    
    % -------------------------------------------------------------
    function setVal(src,~)
      global cfgSet
      if iscell(src.String)
        cfgSet.SetValue(src.Tag, src.String{src.Value});
      else
        cfgSet.SetValue(src.Tag, src.String);
      end
    end
    
    % -------------------------------------------------------------
    function cfgSave(~,~)
      global cfgSet
      cfgSet.Save();
      close;
    end
    
    % -------------------------------------------------------------
    function cfgExit(~,~)
        close;
    end