function msg = MatchMessages(errcode)

if nargin==0
    errcode = [];
end

msgs = {
    {-1, 'No application output generated',  'Functions MATCH, Parameter Values MATCH'} 
    { 3, 'No application output generated.', 'Functions MATCH, Parameter Values DIFFERENT'} 
    { 7, 'No application output generated',  'Functions DIFFERENT, Parameter Values DIFFERENT'} 
    { 0, 'MATCH',  'Functions MATCH, Parameter Values MATCH'} 
    { 4, 'MATCH',  'Functions MATCH, Parameter Values DIFFERENT'} 
    { 8, 'MATCH',  'Functions DIFFERENT, Parameter Values DIFFERENT.'} 
    { 1, 'DIFFERENT',  'Functions MATCH, Parameter Values MATCH'} 
    { 5, 'DIFFERENT',  'Functions MATCH, Parameter Values DIFFERENT'} 
    { 9, 'DIFFERENT',  'Functions DIFFERENT, Parameter Values DIFFERENT'}     
};

msg = msgs;
if isempty(errcode)
    return;
end

for ii=1:length(msgs)
    if msgs{ii}{1}==errcode
        msg = msgs{ii}(2:3);
    end
end

