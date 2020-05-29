function checkForHomerUpdates()
    url = 'http://bu.edu/neurophotonics/research/fnirs/homer3';
    updateAvailable = 0;
    try
        s = urlread(url,'timeout',2);
    catch
        % app is offline or server could not be reached
        return
    end
    updateTxt = ''; % Get information about update from s
    vrnnum = getVernum();
    % Do something to updateAvailable flag

    if (updateAvailable)
        choice = questdlg(['An update for Homer3 is available: ',...
            updateTxt,...
            ' Would you like to download it?'],...
            'Update Available',...
            'Yes','Remind me later','Don''t show this again',...
            'Remind me later');
        switch choice
            case 'Yes'
                % Open browser to update page
                web(url);    
            case 'Don''t ask again'
                % Prevent this prompt for showing until next version
        end
    end
end