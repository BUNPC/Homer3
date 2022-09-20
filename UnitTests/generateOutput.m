function generateOutput(dataTree)
global UNIT_TEST

if dataTree.IsEmpty()
    return
end

UNIT_TEST = true; %#ok<NASGU>
iG = dataTree.GetCurrElemIndexID();
banner = sprintf('Re-calculating derived data at %s with the following processing stream:\n\n', char(datetime(datetime, 'Format','HH:mm:ss, MMMM d, yyyy')));
dataTree.PrintProcStream(banner);
dataTree.groups(iG).Calc();
dataTree.groups(iG).Save();
UNIT_TEST = false;

