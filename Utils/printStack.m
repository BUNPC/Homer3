function printStack()

fprintf('-----------------\n');
fprintf('Error call stack:\n');
fprintf('-----------------\n');
s = dbstack;
for ii=2:length(s)
    fprintf('In %s > %s, (line %d)\n', s(ii).file, s(ii).name, s(ii).line);
end
fprintf('\n\n');
