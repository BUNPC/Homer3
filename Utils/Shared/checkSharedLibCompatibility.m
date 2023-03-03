function v = checkSharedLibCompatibility()
v = {};
libs = parseGitSubmodulesFile();
searchpaths = path();
if ismac()
    delimiter = ':';
else
    delimiter = ';';
end
searchpaths = str2cell(searchpaths, delimiter);
for jj = 1:size(libs,1)
    kk = 2;
    appnamePath = libs{jj,1};
    [~, appname] = fileparts(appnamePath);
    v{jj,1} = appname;
    for ii = 1:length(searchpaths)
        if ~isempty(strfind(searchpaths{ii}, appname))
            if ispathvalid([filesepStandard(searchpaths{ii}), 'Version.txt'], 'file')
                pname = fileparts(filesepStandard(searchpaths{ii}));
                v{jj,kk} = filesepStandard(searchpaths{ii});
                v{jj,kk+1} = getVernum(appname, pname);                
                v{jj,kk+2} = versionstr2num(getVernum(appname, pname));
                fprintf('Found %s, v(%s)  in  %s\n', appname, v{jj,kk},  filesepStandard(searchpaths{ii}));
                kk = kk+3;
            end
        end
    end
end

