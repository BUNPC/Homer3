function checkForHomerUpdates()
    
    cfg = ConfigFileClass();
    
    % If user has Check For Updates enabled
    if (strcmp(cfg.GetValue('Check For Updates'),'on'))

        % If it has been a week since Homer checked for an update
        if (datetime - cfg.GetValue('Last Checked For Update') > duration(168,0,0))

            url = 'http://bu.edu/neurophotonics/research/fnirs/homer3';
            promptFlag = 0;

            [s,status] = urlread(url,'timeout',4);
            if (~status)
                % App is offline or server could not be reached
                fprintf('Server could not be reached to check for updates.') 
                return
            end

            cfg.SetValue('Last Checked For Update', datetime);

            % Open a hidden web browser 
            wb = com.mathworks.mde.webbrowser.WebBrowser.createBrowser;
            wb.setCurrentLocation(url);
            p = getParentRecursive(wb);
            p.setVisible(0);

%             out = regexp(s, '<a id="version">(.*?)<\/a>', 'match')
            vrnum = getVernum();  % Compare to current version and set promptFlag
%             if (vrnum < updateTxt) & (cfg.GetValue('LatestUpdateRefused') < updateTxt)
%               promptFlag = 1;
%             end

            if (promptFlag)
                choice = questdlg(['An update for Homer3 is available: ',...
                    updateTxt,...
                    ' Would you like to download it?'],...
                    'Update Available',...
                    'Yes','Remind me later','Don''t show this again',...
                    'Remind me later');
                switch choice
                    case 'Yes'
                        % Open browser to update page
                        close(wb);
                        web(url);    
                    case 'Don''t ask again'
                        cfg.SetValue('Check For Updates', 'off');
                end

            end

            pause(1);  % To ensure <script> is run
            close(wb);
            cfg.Save();

        end
    
    end
    
    cfg.Close();
    
end