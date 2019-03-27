function simulateGroupData(template, groupname, nsubj, nruns)

% 
% Usage:
%    
%    simulateGroupData(template, groupname, nsubj, nruns)
%
% Description:
%
%    Generate a group of .nirs files from one .nirs file used as a template; the group 
%    consists of nsubj number of subjects and nruns number of runs in each subject. The 
%    data for the generated .nirs files is based on the data from the data file to which 
%    a random component is added. 
%
% Example 1: 
%    
%    Generate a group named group1 based on data from the file ./template. This group 
%    should have 4 subjects with 2, 1, 3 and 3 runs in the 4 subjects respectively.
%    Note: ./template is in our data directory but we don't want to be part of the 
%    group so we rename it to be without the .nirs extensionto avoid moving it out of 
%    the directory. 
%
%      simulateGroupData('./template','group1',4,[2,1,3,3])
%
%

if length(nruns)~=nsubj
    nruns=ones(1,nsubj)*nruns(1);
end
if ~exist('rcoeff','var') || (exist('rcoeff','var') && length(rcoeff)<nsubj)
    rcoeff = ones(nsubj,1)*50;
end

load(template,'-mat');
if exist('aux10')
    aux=aux10;
end

if isempty(groupname)
    k1=[findstr(template,'/') findstr(template,'\')];
    k1=sort(k1);
    template=template(k1(end)+1:end);
    k2=findstr(template,'.nirs');
    subjname=template(1:k2-1);
else
    subjname=groupname;
end

d0=d;
for jj=1:nsubj
    for ii=1:nruns(jj)
        dmean = mean(d(:))/10;
        dr=dmean.*rand(size(d,1),size(d,2));
        d=d0+dr;
        kk=ii;
        while 1
            if(kk>9)
                filename = [subjname '_run' num2str(kk) '.nirs'];
            else
                filename = [subjname '_run0' num2str(kk) '.nirs'];
            end
            if exist(filename,'file')
                kk=kk+1;
                continue;
            else
                break;
            end
        end
        save(filename, '-mat', 'SD', 't', 'd', 's','aux');
    end
end
