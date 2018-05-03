function [filename, pathname] = createDefaultConfigFile()

% This pause is a workaround for a matlab bug in version
% 7.11 for Linux, where uigetfile won't block unless there's
% a breakpoint.
pause(.5);
[filename, pathname] = uigetfile('*.cfg', 'Load Process Options File' );
if filename==0
    ch = menu( sprintf('Loading default config file.'),'Okay');
    filename = './processOpt_default.cfg';
    success = true;
    if exist(filename,'file')
        delete(filename);
        if exist(filename,'file')
            success = false;
        end
    end
    if success
        procStreamFileGen(filename);
    end
else
    filename = [pathname filename];
end
