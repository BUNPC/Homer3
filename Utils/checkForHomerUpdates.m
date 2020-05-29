function checkForHomerUpdates()
    url = 'http://bu.edu/neurophotonics/research/fnirs/homer3';
    try
        s = urlread(url,'timeout',2);
    catch
        % app is offline or server could not be reached
    end
    updateTxt = ''; % Get information about update from s
    vrnnum = getVernum();
%     fprintf("Homer3 version %s\n",[vrnnum{1} '.'
%                                                 vrnnum{2} '.'
%                                                 vrnnum{3} '.'
%                                                 vrnnum{4} ]);
    % add code to check the returned latest version info and to compare with the current version of the executing software and prompt user of an update with update notes
    updateAvailable = 1;
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
            case 'Don''t show this again'
                % Prevent this prompt for showing until next version
        end
    end
end