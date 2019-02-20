classdef DataFilesClass < handle
    
    properties
        files;
        filesErr;
        err;
        errmsg;
        sd_common;
        pathnm;
        handles;
        listboxFiles; 
        listboxFiles2;
        loadData;        
    end
    
    methods
        
        % ----------------------------------------------------
        function obj = DataFilesClass(varargin)
            if ~isempty(varargin)
                args = varargin{1};
            else
                args = [];
            end
            
            nargs = length(args);
            if nargs==0
                obj.handles = [];
                obj.pathnm = pwd;
            elseif nargs==1
                if isstruct(args{1})
                    obj.handles = args{1};
                    obj.pathnm = pwd;
                elseif ischar(args{1})
                    obj.handles = [];
                    obj.pathnm = args{1};
                else
                    obj.handles = [];
                    obj.pathnm = pwd;                    
                end
            elseif nargs==2
                obj.handles = args{1};
                obj.pathnm = args{2};
            else
                obj.handles = [];
                if ischar(args)
                    obj.pathnm = args;
                else
	                obj.pathnm = pwd;
	            end
            end
            obj.filesErr = struct([]);
            obj.errmsg = {};
            obj.sd_common = {};
            obj.loadData = -1;
            
            foo = mydir(obj.pathnm);
            if ~isempty(foo) && ~foo(1).isdir
                obj.files = foo;
            end
        end
        
        
        % ----------------------------------------------------
        function findDataSet(obj, type)
                       
            obj.files = mydir(['./*.', type]);
            if isempty( obj.files )
                
                % If there are no .nirs files in current dir, don't give up yet - check
                % the subdirs for .nirs files.
                dirs = mydir();
                for ii=1:length(dirs)
                    if dirs(ii).isdir && ...
                            ~strcmp(dirs(ii).name,'.') && ...
                            ~strcmp(dirs(ii).name,'..') && ...
                            ~strcmp(dirs(ii).name,'hide')
                        
                        dirs(ii).idx = length(obj.files)+1;
                        cd(dirs(ii).name);
                        foos = mydir(['./*.', type]);
                        nfoos = length(foos);
                        if nfoos>0
                            for jj=1:nfoos
                                foos(jj).subjdir      = dirs(ii).name;
                                foos(jj).subjdiridx   = dirs(ii).idx;
                                foos(jj).idx          = dirs(ii).idx+jj;
                                foos(jj).filename     = foos(jj).name;
                                foos(jj).name         = [dirs(ii).name, '/', foos(jj).name];
                                foos(jj).map2group    = struct('iGroup',0, 'iSubj',0, 'iRun',0);
                            end
                            
                            % Add .nirs file from current subdir to files struct
                            if isempty(obj.files)
                                obj.files = dirs(ii);
                            else
                                obj.files(end+1) = dirs(ii);
                            end
                            obj.files(end+1:end+nfoos) = foos;
                        end
                        cd('../');
                        
                    end
                end
            end
            
        end
        
        
        % ----------------------------------------------------
        function getDataFile(obj, filename)
            obj.files = mydir(filename);
        end
        
        
        
        % --------------------------------------------------------------------------------------------
        function dispErrmsgs(obj)
            
            
            if ~isempty(obj.errmsg)
                hFig = figure('numbertitle','off','menubar','none','name','Errors Found','units','pixels',...
                    'position',[200 500 350 450],'resize','on');
                hErrListbox = uicontrol('parent',hFig,'style','listbox','string',obj.errmsg,...
                    'units','normalized','position',[.1 .25 .8 .7],'value',1);
                hButtn = uicontrol('parent',hFig,'style','pushbutton','tag','pushbuttonOk',...
                    'string','Ok','units','normalized','position',[.2 .1 .25 .1],...
                    'callback',@obj.pushbuttonOk_Callback);
                set(hFig,'units','normalized', 'resize','on');
                p = get(hFig, 'position');
                if p(2)+p(4)>.95
                    d = (p(2)+p(4)) - .95;
                    set(hFig, 'position', [p(1), p(2)-d, p(3), p(4)]);
                end
                
                % Block execution thread until user presses the Ok button
                while ishandle(hFig)
                    pause(1);
                end
                
                obj.fixOrUpgrade();
                
                % Remove any files from data set that have fatal errors
                obj.filesErr = mydir('');
                jj=1;
                kk=1;
                cc=[];
                for ii=1:length(obj.flags)
                    if obj.flags(ii).errCount>0
                        obj.filesErr(kk)=obj.files(ii);
                        kk=kk+1;
                        if ~obj.files(ii).isdir
                            cc(jj)=ii;
                            jj=jj+1;
                        end
                    end
                end
                obj.files(cc)=[];
                
                % remove any directories from 'files' struct if they have no files
                jj=1;
                cc=[];
                for ii=1:length(obj.files)
                    if ii<length(obj.files)
                        if obj.files(ii).isdir && obj.files(ii+1).isdir
                            cc(jj)=ii;
                            jj=jj+1;
                        end
                    elseif ii==length(obj.files)
                        if obj.files(ii).isdir
                            cc(jj)=ii;
                            jj=jj+1;
                        end
                    end
                end
                obj.files(cc)=[];
                
            end
            
        end
        
        
        % --------------------------------------------------------------------------------------------
        function pushbuttonOk_Callback(obj, hObject, eventdata)
            
            delete(get(hObject,'parent'));
            
        end
        
        
        
        % --------------------------------------------------------------------------------------------
        function Display(obj)
            
            if isempty(obj.handles)
                return;
            end
            
            hText     = obj.handles.textStatus;
            hListbox1 = obj.handles.listboxFiles;
            hListbox2 = obj.handles.listboxFilesErr;
            
            % Set listbox for valid .nirs files
            obj.listboxFiles = cell(length(obj.files),1);
            nFiles=0;
            for ii=1:length(obj.files)
                if obj.files(ii).isdir
                    obj.listboxFiles{ii} = obj.files(ii).name;
                elseif ~isempty(obj.files(ii).subjdir)
                    obj.listboxFiles{ii} = ['    ', obj.files(ii).filename];
                    nFiles=nFiles+1;
                else
                    obj.listboxFiles{ii} = obj.files(ii).name;
                    nFiles=nFiles+1;
                end
            end
            
            % Set listbox for invalid .nirs files
            obj.listboxFiles2 = cell(length(obj.filesErr),1);
            nFilesErr=0;
            for ii=1:length(obj.filesErr)
                if obj.filesErr(ii).isdir
                    obj.listboxFiles2{ii} = obj.filesErr(ii).name;
                elseif ~isempty(obj.filesErr(ii).subjdir)
                    obj.listboxFiles2{ii} = ['    ', obj.filesErr(ii).filename];
                    nFilesErr=nFilesErr+1;
                else
                    obj.listboxFiles2{ii} = obj.filesErr(ii).name;
                    nFilesErr=nFilesErr+1;
                end
            end
                                   
            % Set graphics objects: text and listboxes if handles exist
            if ~isempty(obj.handles)
                % Report status in the status text object
                set( hText, 'string', { ...
                        sprintf('%d files loaded successfully',nFiles), ...
                        sprintf('%d files failed to load',nFilesErr) ...
                    } );
                
                if ~isempty(obj.files)
                    set(hListbox1, 'value',1)
                    set(hListbox1, 'string',obj.listboxFiles)
                end
                
                if ~isempty(obj.filesErr)
                    set(hListbox2, 'visible','on');
                    set(hListbox2, 'value',1);
                    set(hListbox2, 'string',obj.listboxFiles2)
                elseif isempty(obj.filesErr)  && ishandle(hListbox2)
                    set(hListbox2, 'visible','off');
                    pos1 = get(hListbox1, 'position');
                    pos2 = get(hListbox2, 'position');
                    set(hListbox1, 'position', [pos1(1) pos2(2) pos1(3) .98-pos2(2)]);
                end
            end
        
        end


        % --------------------------------------------------------------------------------------------
        function reportGroupErrors(obj)
            
            nSD = length(obj.sd_common);
            if nSD > 1
                
                count = 1;
                for ii=1:nSD
                    obj.errmsg{count} = sprintf('SD%d',ii);
                    kk = find(uniqueSD==ii);
                    for jj=1:length(kk)
                        obj.errmsg{count+jj} = sprintf('  %s', obj.files(kk(jj)).name);
                    end
                    count = count+jj+1;
                end
                
                hFig = figure('numbertitle','off','menubar','none','name','File Group Error Report','units','normalized',...
                    'position',[.20, .20, .25, .60], 'resize','on');
                
                hErrListbox = uicontrol('parent',hFig,'style','listbox','string',obj.errmsg,...
                    'units','normalized','position',[.1 .25 .8 .7],'value',1);
                hErrText = uicontrol('parent',hFig,'style','text','string','WARNING: More than one SD geometry found. Might cause errors.',...
                    'units','normalized',    'position',[.1 .15 .7 .055],'horizontalalignment','left');
                hErrText2 = uicontrol('parent',hFig,'style','text','string','Do you still want to load this data set or select a different one?',...
                    'units','normalized',   'position',[.1 .095 .7 .055],'horizontalalignment','left');
                hButtnLoad = uicontrol('parent',hFig,'style','pushbutton','tag','pushbuttonLoad',...
                    'string','Load','units','normalized','position',[.2 .03 .20 .05],...
                    'callback',@obj.pushbuttonLoadDataset_Callback);
                hButtnSelectAnother = uicontrol('parent',hFig,'style','pushbutton','tag','pushbuttonSelectAnother',...
                    'string','Select Another','units','normalized','position',[.4 .03 .30 .05],...
                    'callback',@obj.pushbuttonLoadDataset_Callback);
                
                set(hErrText,'units','pixels');
                set(hErrText2,'units','pixels');
                set(hButtnLoad,'units','pixels');
                set(hButtnSelectAnother,'units','pixels');
                
                % Block execution thread until user presses the Ok button
                while obj.loadData==-1
                    pause(1);
                end
                
            else
                obj.loadData = 1;
            end

        end
        
        
        % -------------------------------------------------------
        function pushbuttonLoadDataset_Callback(obj, hObject)
            
            hp = get(hObject,'parent');
            hc = get(hp,'children');
            for ii=1:length(hc)
                
                if strcmp(get(hc(ii),'tag'),'pushbuttonLoad')
                    hButtnLoad = hc(ii);
                elseif strcmp(get(hc(ii),'tag'),'pushbuttonSelectAnother')
                    hButtnSelectAnother = hc(ii);
                end
                
            end
            
            if hObject==hButtnLoad
                delete(hButtnSelectAnother);
                obj.loadData = 1;
            elseif hObject==hButtnSelectAnother
                delete(hButtnLoad);
                obj.loadData = 0;
            end
            delete(hp);
            
        end
            
        
        % ----------------------------------------------------------
        function b = isempty(obj)
            if isempty(obj.files)
                b = true;
            else
                b = false;
            end
        end

        
    end
    
    
end
