function [status, versold, versnew, apps, appdirs] = updateVersions(changelevel, appname)
%  
% Syntax:
%   [status, versold, versnew, apps, appdirs] = updateVersions(changelevel, appname)
%
% Description:  
%   Update version numbers of main repo and supporting libraries with independent versions
%   
% Input: 
%   changelevel - String specifying the significance of the changes. This determines which number 
%                 first middle or last is incremented. The possible values are 
%
%                   'majormajor'
%                   'major'
%                   'minor'
%
% Examples:
%
%   [status, versold, versnew] = updateVersions('minor');
%       Utils:		v1.1.2  -->  v1.1.3
%       DataTree:		v1.6.0  -->  v1.6.1
%       FuncRegistry:		no changes
%       homer3:		v1.72.0  -->  v1.72.1
%   
%
%   [status, versold, versnew] = updateVersions('major');
%       Utils:		v1.1.2  -->  v1.2.0
%       DataTree:		v1.6.0  -->  v1.7.0
%       FuncRegistry:		no changes
%       homer3:		v1.72.0  -->  v1.73.0
%
%
%   [status, versold, versnew] = updateVersions('major', 'AtlasViewerGUI');
%       Utils:		v1.1.2  -->  v1.2.0
%       DataTree:		v1.6.0  -->  v1.7.0
%       FuncRegistry:		no changes
%       homer3:		v1.72.0  -->  v1.73.0
%
%
%
if ~exist('appname','var') || isempty(appname)
    appname = getNamespace();
    msg = sprintf('App name missing. Namespace not set to app name. Please provide app name.\n');    
    if isempty(appname)
        fprintf(msg);
        return;                
    end
    if isempty(which([appname, '.m']))
        fprintf(msg);
        return
    end
end
setNamespace(appname);

[apps, vers, appdirs] = getVersions();

if ~exist('changelevel','var')
    changelevel = repmat({'minor'},length(apps),1);
elseif ischar(changelevel)
    changelevel = repmat({changelevel},length(apps),1);    
end

versold = vers;
versnew = vers;

status = zeros(length(apps),1);
for ii = 1:length(apps)
    status(ii) = hasChanges(appdirs{ii});    
    if status(ii) > 0
        [~, n1] = versionstr2num(versold{ii});
        n1 = incrementVersion(n1, changelevel{ii});
        versnew{ii} = versionnum2str(n1);
        fprintf('%s:\t\tv%s  -->  v%s\n', apps{ii}, versold{ii}, versnew{ii});
        updateVersionFile(appdirs{ii}, versnew{ii});
    else
        fprintf('%s:\t\tno changes\n', apps{ii});        
    end
end
deleteNamespace(appname);



% --------------------------------------------------------------------------
function [apps, vers, appdirs] = getVersions()
for kk = 1:2
    [apps, vers, appdirs] = dependencies();
    [v, a] = getVernum();
    apps{end+1} = a;
    vers{end+1} = v;
    appdirs{end+1} = getAppDir();
    for ii = 1:length(appdirs)
        repo = filesepStandard(appdirs{ii});
        versionFile = [repo, 'Version.txt'];
        if hasChanges(repo, 'Version.txt')
            % fprintf('Resetting %s\n', versionFile);
            gitRevert(repo, 'Version.txt');
        end
    end
end


% --------------------------------------------------------------------------
function updateVersionFile(repo, vernew)
versionFile = [filesepStandard(repo), 'Version.txt'];
if ~ispathvalid(versionFile,'file')
    return;
end
fd = fopen(versionFile, 'w');
fprintf(fd, vernew);
fclose(fd);




% --------------------------------------------------------------------------
function appname = getAppName()
appname = getNamespace();
if ~isempty(appname)
    return
end
pname = which('setpaths.m');
p = fileparts(pname);
[~, appname] = fileparts(p);
setNamespace(appname);


