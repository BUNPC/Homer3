function generateOutput(dataTree)
global UNIT_TEST

if dataTree.IsEmpty()
    return
end

UNIT_TEST = true; %#ok<NASGU>
iG = dataTree.GetCurrElemIndexID();
dataTree.groups(iG).Calc();
dataTree.groups(iG).Save();
UNIT_TEST = false;

