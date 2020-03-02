classdef ExportTable < handle
   
    properties
        filename
        pathname
        datatitle
        cells
        fd 
    end
    
    methods
        
        % ----------------------------------------------------------------
        function obj = ExportTable(filename, datatype, cells)
            obj.pathname = '';
            obj.filename = '';
            obj.datatitle = '';
            obj.cells = TableCell.empty();
            obj.fd = -1;

            if nargin==0
                return;
            end
            if nargin==1
                datatype = '';
                cells = TableCells.empty();
            end
            
            [pname, fname] = fileparts(filename);
            ext = sprintf('_%s.txt', datatype);
            obj.pathname = filesepStandard(pname);
            obj.filename = [fname, ext];
            obj.datatitle = sprintf('%s: Exported %s data', fname, datatype);
           
            obj.cells = cells;

        end
        
        
        % ----------------------------------------------------------------
        function Open(obj)
            if obj.fd > -1
                return;
            end
            obj.fd = fopen([obj.pathname, obj.filename], 'wt');
        end
        
        
        % ----------------------------------------------------------------
        function Save(obj)
            fprintf(obj.fd, '%s\n', obj.datatitle);
            fprintf('%s\n', obj.datatitle);
            for ii=1:size(obj.cells,1)
                for jj=1:size(obj.cells,2)
                    obj.cells(ii,jj).Write(obj.fd);
                end
                fprintf(obj.fd, '\n');
            end
        end
        
        
        % ----------------------------------------------------------------
        function Close(obj)
            if obj.fd < 0
                return;
            end
            fclose(obj.fd);
            obj.fd = -1;
        end
        
    end
    
end

