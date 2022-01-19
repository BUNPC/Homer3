function snirf = demo_snirf_readfile(fname)

% Syntax: 
%
%   snirf = demo_snirf_readfile() 
%
% Description:
%
%   Demo of how to read individual SNIRF fields using SnirfClass methods.
%  
% Examples:
% 
%   In each example, make sure the standard Examples .snirf files are there
%   by first running demo_snirf (only once), then call this function.
%
%       demo_snirf
%
%   1. Read and print data from default .snirf file 
%
%       snirf = demo_snirf_readfile();
%
%   2. Read and print data from named files
%
%       snirf = demo_snirf_readfile('Simple_Probe.snirf');
%       snirf = demo_snirf_readfile('FingerTapping_run3_tdmlproc.snirf');
%       snirf = demo_snirf_readfile('neuro_run01.snirf');
%      
%

REPLACE_CODE_WITH_SNIRF_INFO_METHOD = true;

if nargin==0
    fname = 'neuro_run01.snirf';
end
rootdirexamples = findexamplesdir(); 
fnamefullpath = findfile(rootdirexamples, fname);
if isempty(fnamefullpath)
    return;
end

%%%%% This is the actual demo showing how to read a .snirf file on the command line

% Create empty snirf object
snirf = SnirfClass();

% Use the SnirfClass LoadYYYY method to load whichever field you want 
fprintf('This is a demo of how to load data from a SNIRF file and convert it to .nirs style data.\n');
fprintf('========================================================================================\n');
fprintf('Displaying data from %s\n\n', fnamefullpath);


% Load the SNIRF fields into empty snirf class object, one at a time 
snirf.LoadMetaDataTags(fnamefullpath);
snirf.LoadData(fnamefullpath);
snirf.LoadProbe(fnamefullpath);
snirf.LoadStim(fnamefullpath);
snirf.LoadAux(fnamefullpath);

% The SnirfClass.Info() method replaces the code in the else statement below. It is essentially 
% the same code adapted to work from within the class. We keep the else statement around for 
% easy viewing of code showing how to load, extract and display SnirfClass data
if REPLACE_CODE_WITH_SNIRF_INFO_METHOD

    snirf.Info();

else 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load meta data tags from file and extract the tag names and values for display
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('    MetaDataTags:\n');
    tags = snirf.GetMetaDataTags();
    for ii=1:length(tags)
        fprintf('        Meta data tag #%d: {''%s'', ''%s''}\n', ii, tags(ii).key, tags(ii).value);
    end
    fprintf('\n');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load data from file and extract .nirs-style d and ml matrices for display
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('    Data (.nirs-style display):\n');
    for ii=1:length(snirf.data)
        
        % Display data matrix dimensions and data type
        d = snirf.data(ii).GetDataTimeSeries();
        pretty_print_struct(d, 8, 1);
        
        % Display meas list dimensions and data type
        ml = snirf.data(ii).GetMeasList();
        pretty_print_struct(ml, 8, 1);
        
    end
    fprintf('\n');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load probe and extract .nirs-style SD structure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('    Probe (.nirs-style display):\n');
    SD = snirf.GetSDG();
    pretty_print_struct(SD, 8, 1);
    fprintf('\n');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load stim from file and extract it for display
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('    Stim (.snirf-style display):\n');
    for ii=1:length(snirf.stim)
        fprintf('        stim(%d): {name = ''%s'', data = [', ii, snirf.stim(ii).name);
        for jj=1:size(snirf.stim(ii).data,1)
            if jj==size(snirf.stim(ii).data,1)
                fprintf('%0.1f', snirf.stim(ii).data(jj,1));
            else
                fprintf('%0.1f, ', snirf.stim(ii).data(jj,1));
            end
        end
        fprintf(']}\n');
    end
    fprintf('\n');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load aux from file and extract nirs-style data for display
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('    Aux (.nirs-style display):\n');
    aux = snirf.GetAuxiliary();
    pretty_print_struct(aux, 8, 1);
    
end
