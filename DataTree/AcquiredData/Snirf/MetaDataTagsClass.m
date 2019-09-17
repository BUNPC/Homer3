classdef MetaDataTagsClass  < FileLoadSaveClass

    properties
        metadata
    end

    methods
        
        % -------------------------------------------------------
        function obj = MetaDataTagsClass(varargin)
            obj.metadata=struct();
            
            % Set class properties not part of the SNIRF format
            obj.fileformat = 'hdf5';
            
            % Set SNIRF fomat properties
            if nargin==0
                return;
	        end
            if nargin==1
                obj.metadata.(varargin{1})='';
                return;
            end            
            obj.metadata.(varargin{1})=varargin{2};
        end
    
    
        % -------------------------------------------------------
        function err = LoadHdf5(obj, fname, parent)
            err = 0;
            
            % Arg 1
            if ~exist('fname','var') || ~exist(fname,'file')
                fname = '';
            end
            
            % Arg 2
            if ~exist('parent', 'var')
                parent = '/nirs/metaDataTags';
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
            pd = 'H5P_DEFAULT';

            try
                % Read metadata
                fid = H5F.open(fname, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
                gid = H5G.open(fid,parent);
                num = H5G.get_num_objs(gid);
                for i=num-1:-1:0
                   key=H5G.get_objname_by_idx(gid,i);
                   mv1=H5D.open(gid,key);
                   obj.metadata.(key)=H5D.read(mv1,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',pd);
                   H5D.close(mv1);
                end
                H5G.close(gid);
                H5F.close(fid);

                if isempty(fieldnames(obj.metadata))
                   err=-1;
                end
            catch ME
                disp(ME.message);
                err = -1;
            end

            obj.err = err;
            
        end

        % -------------------------------------------------------
        function SaveHdf5(obj, fname, parent)
            obj.filename=fname;
            typemap.char='H5T_C_S1';
            typemap.double='H5T_IEEE_F64LE';
            typemap.single='H5T_IEEE_F32LE';

            pd = 'H5P_DEFAULT';

            fid = H5F.open(fname, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
            pos=split(parent,'/');
            level=1;
            mid{1}=fid;
            for i=1:length(pos)
                if(isempty(pos{i}))
                    continue;
                end
                level=level+1;
                try 
                    mid{level} = H5G.open(mid{level-1},pos{i},pd);
                catch
                    mid{level} = H5G.create(mid{level-1},pos{i},pd,pd,pd);
                end
            end
            metakeys=fieldnames(obj.metadata);
            for i=1:length(metakeys)
               val=obj.metadata.(metakeys{i});
               mv1= H5D.create(mid{end},metakeys{i},H5T.copy(typemap.(class(val))),H5S.create_simple(ndims(val), fliplr(size(val)),fliplr(size(val))),pd);
               H5D.write(mv1,'H5ML_DEFAULT','H5S_ALL','H5S_ALL',pd,val);
               H5D.close(mv1);
            end
            for i=length(mid):-1:2
                H5G.close(mid{i});
            end
            H5F.close(fid);
        end
        
        
        % -------------------------------------------------------
        function B = eq(obj, obj2)
            B=isequaln(obj, obj2);
        end
        
        
        
        % -------------------------------------------------------
        function Add(obj, name, value)
            obj.metadata.(name) = value;
        end
        
        % -------------------------------------------------------
        function Set(obj, name, value)
            obj.metadata.(name) = value;
        end
        
        % -------------------------------------------------------
        function val=Get(obj, name)
            val=[];
            if(nargin==1)
                val=obj.metadata;
            elseif(isfield(obj.metadata,name))
                val=obj.metadata.(name);
            end
        end
        
    end
    
end