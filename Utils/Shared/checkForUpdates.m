function checkForUpdates(appname)
global cfg

cfg = InitConfig(cfg);

% If user has Check For Updates enabled
if (strcmp(cfg.GetValue('Check For Updates'),'on'))
    
    % If it has been a week since Homer checked for an update
    if (datetime - GetLastCheckForUpdates() > duration(168,0,0))
        url = sprintf('https://openfnirs.org/software/homer/%s/', appname);
        [s,status] = urlread(url,'timeout',4);        
        if (~status)
            % App is offline or server could not be reached
            fprintf('Server could not be reached to check for updates.')
            return
        end
        SetLastCheckForUpdates();
        version = regexp(s, 'id="version">(.*?)<\/', 'tokens');
        if isempty(version)
            return
        end
        web_vrnum = version{1}{1};
        this_vrnum = getVernum();
        promptFlag = compareVernum(web_vrnum, this_vrnum);  % If fetched vernum is greater

        % Open a hidden web browser        
        if (promptFlag)            
            wb = com.mathworks.mde.webbrowser.WebBrowser.createBrowser;
            wb.setCurrentLocation(url);
            p = getParentRecursive(wb);
            p.setVisible(0);            
            choice = questdlg(sprintf('Version of your copy of %s is v%s\nA newer version v%s is available.\nWould you like to download?', appname, this_vrnum, web_vrnum), ...
                             'Update Available', ...
                             'Yes', ...
                             'Remind me later', ...
                             'Don''t show this again', ...
                             'Remind me later');            
            if strcmp(choice, 'Yes')
                web('https://github.com/BUNPC/AtlasViewer/releases');
                close(wb);
            elseif strcmp(choice, 'Don''t show this again')
                web('https://github.com/BUNPC/AtlasViewer');
                cfg.SetValue('Check For Updates', 'off');
            end            
            close(wb);
        end        
        pause(1);  % To ensure <script> is run
        
    end
    
end



% ------------------------------------------------------------------------------
function v1_greater = compareVernum(v1, v2)
v1_greater = false;
v1num = versionstr2num(v1);
v2num = versionstr2num(v2);
if v1num > v2num
    v1_greater = true;
end    


