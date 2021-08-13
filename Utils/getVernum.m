function [out1] = getVernum()
out1 = [];
ns = getNamespace();
if isempty(ns)
    return;
end
if strcmp(ns, 'AtlasViewerGUI')
    if nargin == 0
        [out1] = getVernum_AtlasViewerGUI();
    end
elseif strcmp(ns, 'Homer3')
    if nargin == 0
        [out1] = getVernum_Homer3();
    end
end


% ---------------------------------------------------------
function [vrnnum] = getVernum_AtlasViewerGUI()

vrnnum{1} = '2';   % Major version #
vrnnum{2} = '15';  % Major sub-version #
vrnnum{3} = '5';   % Minor version #
vrnnum{4} = '0';   % Minor sub-version # or patch #: 'p1', 'p2', etc



% ---------------------------------------------------------
function [vrnnum] = getVernum_Homer3()

vrnnum{1} = '1';   % Major version #
vrnnum{2} = '32';  % Major sub-version #
vrnnum{3} = '4';   % Minor version #
vrnnum{4} = '0';   % Minor sub-version # or patch #: 'p1', 'p2', etc

