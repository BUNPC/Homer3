classdef SnirfFilesClass < DataFilesClass
    
    properties
        flags
    end
    
    methods
        
        % -----------------------------------------------------------------------------------
        function obj = SnirfFilesClass(varargin)

            % Call base class constructor explicitly in order to pass 
            % our derived class arguments to it.
            obj@DataFilesClass(varargin);
            obj.GetDataSet();
            
        end
        
        
        % -----------------------------------------------------------------------------------
        function GetDataSet(obj)
            
            cd(obj.pathnm);
            currdir = obj.pathnm;
            
            % Init output parameters
            % Get .nirs file names from current directory. If there are none
            % check sub-directories.
            obj.findDataSet('snir5');
            
            files0 = obj.files;
            
            % First get errors for .nirs files as individual files
            obj.getFileErrors();
                        
            % Now check the .nirs files data set as a whole. That is make
            % sure they all belong to the same group. This means only that the
            % SD geometries are compatible.
            obj.checkFormatAcrossFiles();
            if ~obj.loadData
                obj.files = mydir('');
                obj.filesErr = files0;
                if isempty( obj.files )
                    fprintf('No loadable .snir5 files found. Choose another directory\n');
                    
                    % This pause is a workaround for a matlab bug in version
                    % 7.xx for Linux, where uigetfile/uigetdir won't block unless there's
                    % a breakpoint.
                    pause(.5);
                    obj.pathnm = uigetdir(currdir,'No loadable .snir5 files found. Choose another directory' );
                    if obj.pathnm~=0
                        obj.GetDataSet();
                    end
                end
            end
            
            %%% Display loaded and error files in GUI
            obj.dispFiles();
            
        end
        
        
        
        % -----------------------------------------------------------------------------------
        function initErrFlags(obj, n)
            
            flag = struct(...
                'FileCorrupt',0 ...
                );
            
            obj.flags = repmat(flag,n,1);
            
        end
        
        
        % -----------------------------------------------------------------------------------
        function getFileErrors(obj)
            
            obj.dispErrmsgs();
            
        end

    

        % -----------------------------------------------------------------------------------
        function checkFormat(obj)
        
            warning('off','MATLAB:load:variableNotFound');
            
            nFiles = length(obj.files);
            obj.flags = initErrFlagsStruct(nFiles);

            % NIRS data set format
            hwait = waitbar(0,sprintf('Checking .nirs format for individual files') );
            for iF=1:nFiles
                
                waitbar(iF/nFiles,hwait,sprintf('Checking file %d of %d',iF,nFiles));
                if obj.files(iF).isdir
                    continue;
                end
                                
            end
            close(hwait);
            
            warning('on','MATLAB:load:variableNotFound');            
            
        end  
        
        
        % -----------------------------------------------------------------------------------
        function fixOrUpgrade(obj)
            
            warning('off','MATLAB:load:variableNotFound');
            
            nFiles = length(obj.files);
            ch_all = zeros(length(obj.files));
            yestoallflag = 0;
            informUserFilesCopiedFlag = 0;
            spatialUnits = 0;
            for iF=1:nFiles
                
                if obj.flags(iF).errCount>0  &&  obj.flags(iF).FileCorrupt==0 &&  ~obj.files(iF).isdir
                    
                    if yestoallflag==1
                        ch=2;
                    else
                        if obj.flags(iF).errCount>0
                            ch = menu(sprintf('Error in %s files.\nDo you want to try to fix it?',obj.files(iF).name),...
                                'Yes','Yes to All','No','No to All');
                        elseif obj.flags(iF).warningCount>0
                            ch = menu(sprintf('Obsolete format in %s files.\nDo you want to try to upgrade to current format?',obj.files(iF).name),...
                                'Yes','Yes to All','No','No to All');
                        end
                    end
                    
                    ch_all(iF) = ch;                    
                    if ch==1 || ch==2
                        
                        % User chose to fix file.
                        savestr = [];
                                                
                    end
                    
                end
                
            end
            
            if informUserFilesCopiedFlag == 1
                menu(sprintf('%d error fixed - original .nirs file saved to .nirs.orig', informUserFilesCopiedFlag),'OK');
            elseif informUserFilesCopiedFlag > 1
                menu(sprintf('%d errors fixed - original .nirs files saved to .nirs.orig', informUserFilesCopiedFlag),'OK');
            end
            warning('on','MATLAB:load:variableNotFound');
                     
        end
        
        
        
        % -----------------------------------------------------------------------------------
        function checkFormatAcrossFiles(obj)
            
            nFiles = length(obj.files);
            uniqueSD = zeros(1,nFiles);
            
            if isempty(obj.files)
                return;
            end
            
            snirf = repmat(SnirfClass(), nFiles, 1);
            hwait = waitbar(0,sprintf('Checking .snir5 format consistency across files: processing 1 of %d',nFiles) );
            for iF=1:nFiles
                
                if obj.files(iF).isdir
                    continue;
                end
                
                waitbar(iF/nFiles,hwait,sprintf('Checking .snir5 format consistency across files: processing %d of %d',iF,nFiles));                
                snirf(iF).Load( obj.files(iF).name );
                pause(1);

            end                
            close(hwait);
                        
            % Report results
            obj.reportGroupErrors(); 
            
        end
                
    end
    
end