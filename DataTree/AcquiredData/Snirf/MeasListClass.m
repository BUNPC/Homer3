classdef MeasListClass < FileLoadSaveClass
    
    % Properties implementing the MeasList fields from the SNIRF spec
    properties
        sourceIndex
        detectorIndex
        wavelengthIndex
        dataType
        dataTypeLabel
        dataTypeIndex   % Used for condition when dataType=99999 ("Processed") and dataTypeLabel='HRF...'
        sourcePower
        detectorGain
        moduleIndex
    end
    
       
    methods

        function obj = MeasListClass(varargin)
            %
            %  Syntax:
            %     obj = MeasListClass()
            %     obj = MeasListClass(ml)
            %     obj = MeasListClass(sourceIndex, detectorIndex, wavelengthIndex)
            %     obj = MeasListClass(sourceIndex, detectorIndex, dataType)
            %     obj = MeasListClass(sourceIndex, detectorIndex, dataType, dataTypeLabel)
            %     obj = MeasListClass(sourceIndex, detectorIndex, dataType, dataTypeLabel, condition)
            %     
            %  Inputs:
            %     ml             - When there's one argument, ml is the measurent list, which 
            %                      can be either a nirs style matrix or a MeasListClass object.
            %     sourceIndex    - When there are more than 2 arguments, ...
            %     detectorIndex  - When there are more than 2 arguments, ...
            %     dataType       - When there are more than 2 arguments, ...
            %     dataTypeLabel  - When there are more than 2 arguments, ...
            %     dataTypeIndex  - When there are more than 2 arguments, ...
            %
            %  Example:
            %
            
            % Fields which are part of the SNIRF spec which are loaded and saved 
            % from/to SNIRF files
            obj.sourceIndex      = 0;
            obj.detectorIndex    = 0;
            obj.wavelengthIndex  = 0;
            obj.dataType         = 0;
            obj.dataTypeLabel    = '';
            obj.dataTypeIndex    = 0;
            obj.sourcePower      = 0;
            obj.detectorGain     = 0;
            obj.moduleIndex      = 0;
            
            dataTypeValues = DataTypeValues();

            if nargin==1 && isa(varargin{1}, 'MeasListClass')
                obj                  = varargin{1}.copy();                    % shallow copy ok because MeasListClass has no handle properties 
            elseif nargin==1 
                obj.sourceIndex      = varargin{1}(1);
                obj.detectorIndex    = varargin{1}(2);
                obj.wavelengthIndex  = varargin{1}(4);
                obj.dataType         = dataTypeValues.Raw.CW.Amplitude;
            elseif nargin==3
                obj.sourceIndex      = varargin{1};
                obj.detectorIndex    = varargin{2};
                obj.dataType         = varargin{3};
            elseif nargin==4
                obj.sourceIndex      = varargin{1};
                obj.detectorIndex    = varargin{2};
                obj.dataType         = varargin{3};
                obj.dataTypeLabel    = varargin{4};
            elseif nargin==5
                obj.sourceIndex      = varargin{1};
                obj.detectorIndex    = varargin{2};
                obj.dataType         = varargin{3};
                obj.dataTypeLabel    = varargin{4};
                obj.dataTypeIndex    = varargin{5};
            end
            
            % These are fields helping to implement the MeasListClass
            % which are NOT part of the SNIRF spec and are not loaded or saved from/to
            % SNIRF files
        end
        
        
        % -------------------------------------------------------
        function obj = LoadHdf5(obj, fname, parent)
            err = 0;
            
            % Arg 1
            if ~exist('fname','var') || ~exist(fname,'file')
                fname = '';
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/snirf/ml_1';
            elseif parent(1)~='/'
                parent = ['/',parent];
            end
            
            % Do some error checking            
            if ~isempty(fname)
                obj.filename = fname;
            else
                fname = obj.filename;
            end
            if isempty(fname)
               err=-1;
               return;
            end
            
            %%%%%%%%%%%% Ready to load from file
            obj.sourceIndex = hdf5read(fname, [parent, '/sourceIndex']);
            obj.detectorIndex = hdf5read(fname, [parent, '/detectorIndex']);
            obj.wavelengthIndex = hdf5read(fname, [parent, '/wavelengthIndex']);
            obj.dataType = hdf5read(fname, [parent, '/dataType']);
            obj.dataTypeLabel = strtrim_improve(hdf5read_safe(fname, [parent, '/dataTypeLabel'], obj.dataTypeLabel));
            obj.dataTypeIndex = hdf5read(fname, [parent, '/dataTypeIndex']);
            obj.sourcePower = hdf5read(fname, [parent, '/sourcePower']);
            obj.detectorGain = hdf5read(fname, [parent, '/detectorGain']);
            obj.moduleIndex = hdf5read(fname, [parent, '/moduleIndex']);
        end

        
        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            if ~exist(fname, 'file')
                fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
                H5F.close(fid);
            end
            
            hdf5write(fname, [parent, '/sourceIndex'], obj.sourceIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/detectorIndex'], obj.detectorIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/wavelengthIndex'], obj.wavelengthIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/dataType'], obj.dataType, 'WriteMode','append');
            hdf5write(fname, [parent, '/dataTypeLabel'], obj.dataTypeLabel, 'WriteMode','append');
            hdf5write(fname, [parent, '/dataTypeIndex'], obj.dataTypeIndex, 'WriteMode','append');
            hdf5write(fname, [parent, '/sourcePower'], obj.sourcePower, 'WriteMode','append');
            hdf5write(fname, [parent, '/detectorGain'], obj.detectorGain, 'WriteMode','append');
            hdf5write(fname, [parent, '/moduleIndex'], obj.moduleIndex, 'WriteMode','append');
        end

                
        % ---------------------------------------------------------
        function idx = GetSourceIndex(obj)
            idx = obj.sourceIndex;
        end
        
        
        % ---------------------------------------------------------
        function idx = GetDetectorIndex(obj)
            idx = obj.detectorIndex;
        end
        
        
        % ---------------------------------------------------------
        function idx = GetWavelengthIndex(obj)
            idx = obj.wavelengthIndex;
        end
        
        
        % ---------------------------------------------------------
        function SetWavelengthIndex(obj, val)
            obj.wavelengthIndex = val;
        end
        
        
        % ---------------------------------------------------------
        function SetDataType(obj, dataType, dataTypeLabel)
            obj.dataType = dataType;
            obj.dataTypeLabel = dataTypeLabel;
        end
        
        
        % ---------------------------------------------------------
        function SetDataTypeLabel(obj, dataTypeLabel)
            obj.dataTypeLabel = dataTypeLabel;
        end
        
        
        % ---------------------------------------------------------
        function [dataType, dataTypeLabel] = GetDataType(obj)
            dataType = obj.dataType;
            dataTypeLabel = obj.dataTypeLabel;
        end
        
        
        % ---------------------------------------------------------
        function dataTypeLabel = GetDataTypeLabel(obj)
            dataTypeLabel = obj.dataTypeLabel;
        end
        
        
        % ---------------------------------------------------------
        function SetCondition(obj, val)
            obj.dataTypeIndex = val;
        end
        
        
        % ---------------------------------------------------------
        function val = GetCondition(obj)
            val = obj.dataTypeIndex;
        end
        
        
        % -------------------------------------------------------
        function b = IsEmpty(obj)
            b = false;
            if obj.sourceIndex==0 && obj.detectorIndex==0
                b = true;
            end
        end
        
    end
    
end

