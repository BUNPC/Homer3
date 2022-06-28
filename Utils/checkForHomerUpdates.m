function checkForHomerUpdates()
global cfg

cfg = InitConfig(cfg);

% If user has Check For Updates enabled
if (strcmp(cfg.GetValue('Check For Updates'),'on'))
    
    % If it has been a week since Homer checked for an update
    if (datetime - GetLastCheckForUpdates() > duration(168,0,0))
        
        url = 'https://openfnirs.org/software/homer/homer3/';        
        [s, status] = urlread(url,'timeout',4);
        if (~status)
            % App is offline or server could not be reached
            fprintf('Server could not be reached to check for updates.')
            return
        end

        SetLastCheckForUpdates();
        
        % Open a hidden web browser and poll openfnirs.org
        % If user has a web browser open MATLAB will unfortunately just
        % open the page there
        wb = com.mathworks.mde.webbrowser.WebBrowser.createBrowser;
        if ~ismac()
            setCurrentLocation(wb, url);
        end
        p = getParentRecursive(wb);
        p.setVisible(0);
        
        % Get latest release info from GitHub API
        release_info = webread('https://api.github.com/repos/BUNPC/Homer3/releases/latest');
        
        tag = release_info.tag_name;
        update_body_text = release_info.body;
        dest = release_info.html_url;
        
        latest_vrnum = tag;
        latest_vrnum(isletter(latest_vrnum)) = [];
        latest_vrnum = transpose(split(latest_vrnum, '.'));
        
        this_vrnum = str2cell(getVernum('Homer3'), '.');
        this_vrnum(isletter(this_vrnum)) = [];
        this_vrnum = transpose(split(this_vrnum, '.'));
        
        promptFlag = compareVernum(latest_vrnum, this_vrnum);  % If fetched vernum is greater
        if (promptFlag)
            choice = questdlg(sprintf([sprintf('An update for Homer3 is available: %s\n', tag),...
                update_body_text,...
                '\nWould you like to download it?']),...
                'Update Available',...
                'Yes','Remind me later','Don''t show this again',...
                'Remind me later');
            if strcmp(choice, 'Yes')
                close(wb);
                web(dest);
                return;
            elseif strcmp(choice, 'Don''t show this again')
                cfg.SetValue('Check For Updates', 'off');
            end
            
        end
        
        pause(1);  % To ensure <script> is run on openfnirs.org
        close(wb);
        
    end
    
end



% ------------------------------------------------------------------------------
function v1_greater = compareVernum(v1, v2)
v1_greater = false;
for i = 1:max([length(v1), length(v2)])
    try
        v1_part = str2num(v1{i});
    catch
        v1_part = 0;
    end
    try
        v2_part = str2num(v2{i});
    catch
        v2_part = 0;
    end
    try  % Version format is unstable
        if v1_part > v2_part
            v1_greater = true;
            return
        elseif v1_part < v2_part
            return
        end
    catch
        return
    end
end

