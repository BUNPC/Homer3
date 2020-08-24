function checkForHomerUpdates()
    
    cfg = ConfigFileClass();
    
    % If user has Check For Updates enabled
    if (strcmp(cfg.GetValue('Check For Updates'),'on'))

        % If it has been a week since Homer checked for an update
         if (datetime - cfg.GetValue('Last Checked For Update') > duration(168,0,0))

            url = 'http://bu.edu/neurophotonics/research/fnirs/homer3';
            promptFlag = false;

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

            version = regexp(s, '<a id="version">(.*?)<\/a>', 'tokens');
            desc = regexp(s, '<p id="description">(.*?)<\/p>', 'tokens');
            try  % Version description might not exist
                updateTxt = [version{1}{1},': ', desc{1}{1}];
            catch
                updateTxt = version{1}{1};
            end
            web_vrnum = str2cell(version{1}{1},'.');
            this_vrnum = getVernum();
            promptFlag = compareVernum(web_vrnum, this_vrnum);  % If fetched vernum is greater
            if (promptFlag)
                choice = questdlg(sprintf(['An update for Homer3 is available:\n',...
                    updateTxt,...
                    '\nWould you like to download it?']),...
                    'Update Available',...
                    'Yes','Remind me later','Don''t show this again',...
                    'Remind me later');
                switch choice
                    case 'Yes'
                        % Open browser to update page
                        close(wb);
                        web('https://github.com/BUNPC/Homer3/wiki/Installing-and-updating-Homer3-with-Git-or-GitHub-Desktop');
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


function v1_greater = compareVernum(v1, v2)
    v1_greater = false;
    for i = 1:max([length(v1), length(v2)])
        v1_part = str2num(v1{i});
        v2_part = str2num(v2{i});
        try  % Version format is unstable
            if v1_part > v2_part
               v1_greater = true
               return
            elseif v1_part < v2_part
                return
            end
        catch
            return
        end
    end
end
