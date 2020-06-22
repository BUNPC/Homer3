classdef ExportTable < handle
   
    properties
        filename
        pathname
        datatype
        datatitle
        cells
        format
        offsetDataRowIdx
        fd        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % ----------------------------------------------------------------
        function obj = ExportTable(filename, datatype, cells, format)
            obj.pathname = '';
            obj.filename = '';
            obj.datatitle = '';
            obj.cells = TableCell.empty();
            obj.fd = -1;

            if nargin==0
                return;
            end
            if ~exist('datatype','var') || isempty(datatype)
                datatype = '';
            end
            if ~exist('cells','var') || isempty(cells)
                cells = TableCell.empty();
            end
            if ~exist('format','var') || isempty(format)
                format = 'text';
            end
            
            [pname, fname] = fileparts(filename);
            
            obj.datatype = datatype;
            obj.datatype(obj.datatype==' ') = [];
            obj.datatype = sprintf('_%s', obj.datatype);
            obj.pathname = filesepStandard(pname);
            obj.filename = [fname, obj.datatype];
            obj.datatitle = sprintf('%s: Exported %s data', fname, datatype);
           
            obj.cells = cells;
            obj.format = format;

            obj.offsetDataRowIdx = 1;
            for ii=1:size(obj.cells,1)
                if isempty(obj.cells(ii,1).name)
                    obj.offsetDataRowIdx = ii+1;
                end
            end
            
            obj.Open()
            obj.Save()
            obj.Close()

        end
        
        
        % ----------------------------------------------------------------
        function Open(obj)
            if ~strcmp(obj.format, 'text') && ~strcmp(obj.format, 'txt')
                return
            end
            if obj.fd > -1
                return;
            end
            obj.fd = fopen([obj.pathname, obj.filename, '.txt'], 'wt');
        end
        
        
        % ----------------------------------------------------------------
        function Save(obj)
            if strcmpi(obj.format, 'text')
                err = obj.SaveText();
            elseif strcmpi(obj.format, 'spreadsheet')
                err = obj.SaveSpreadsheet();
                if err==-1
                    err = obj.SaveText();
                end
            end
        end
        
                
        % ----------------------------------------------------------------
        function Close(obj)
            if ~strcmp(obj.format, 'text') && ~strcmp(obj.format, 'txt')
                return
            end
            if obj.fd < 0
                return;
            end
            fclose(obj.fd);
            obj.fd = -1;
        end
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
    
        
        % ----------------------------------------------------------------
        function err = SaveText(obj)            
            err = 0;
            fprintf(obj.fd, '%s\n', obj.datatitle);
            fprintf('%s\n', obj.datatitle);
            h =  waitbar_improved(0, sprintf('Exporting %s to text ... 0%% complete.', obj.filename));
            for ii=1:size(obj.cells,1)
                waitbar_improved(ii/size(obj.cells,1), h, sprintf('Exporting %s to text ... %d%% complete', obj.filename, uint32(100 * ii/size(obj.cells,1))));
                for jj=1:size(obj.cells,2)
                    obj.cells(ii,jj).Write(obj.fd);
                end
                fprintf(obj.fd, '\n');
            end
            close(h);
        end
        
        
        % ----------------------------------------------------------------
        function err = SaveSpreadsheet(obj)
            err = 0;
            idxD = obj.offsetDataRowIdx;
            
            headers = cell(1, size(obj.cells,2));
            data    = cell(size(obj.cells(idxD:end,:),1), size(obj.cells,2));
            
            for jj=1:size(obj.cells,2)
                headers{jj} = obj.cells(2,jj).name;
            end
            
            % 
            h =  waitbar_improved(0, sprintf('Exporting %s to Excel ... 0%% complete.', obj.filename));
            for ii = idxD:size(obj.cells,1)
                waitbar_improved(ii/size(obj.cells,1), h, sprintf('Exporting %s to Excel ... %d%% complete', obj.filename, uint32(100 * ii/size(obj.cells,1))));
                for jj=1:size(obj.cells,2)
                    if isnumber(obj.cells(ii,jj).name)
                        data{ii-idxD+1,jj} = str2double(obj.cells(ii,jj).name);
                    else
                        data{ii-idxD+1,jj} = obj.cells(ii,jj).name;
                    end
                end
            end
            close(h);
            
            if isfile_private([obj.pathname, obj.filename, '.xls'])
                delete([obj.pathname, obj.filename, '.xls']);
            end
            try
                xlswrite([obj.pathname, obj.filename, '.xls'], [headers; data]);
            catch ME
                msg{1} = sprintf('ERROR: Failed to export to Excel format. This may be because Excel ');
                msg{2} = sprintf('is not installed on your computer. Do you want to export to a ');
                msg{3} = sprintf('text file instead?');
                q = MenuBox([msg{:}], {'Yes','No'});
                err = -q;
            end
        end
        
    end
    
end

