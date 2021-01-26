% SYNTAX:
% dod = hmrR_Intensity2OD( intensity )
%
% UI NAME:
% Intensity_to_Delta_OD
%
% DESCRIPTION:
% Converts intensity data to optical density
%
% INPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% OUTPUT:
% dod - SNIRF data type where the d matrix is change in optical density
%
% USAGE OPTIONS:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD(data)
%
function dod = hmrR_Intensity2OD( intensity )

% convert to dod
dod = DataClass().empty();
for ii=1:length(intensity)
    dod(ii) = DataClass();
    d = intensity(ii).GetDataTimeSeries();
    
    % Optional (user prompt): Adding dc offset if intensity (d) has negative values
    if ~isempty(d<=0)
        quest = {'Intensity signal has negative values. If you would like to add a dc offset, please click YES. If you would like to proceed with negative values, hit CANCEL.'};
        dlgtitle = 'Warning';
        btn1 = 'YES';
        btn2 = 'CANCEL';
        detbtn = btn1;
        answer = questdlg(quest,dlgtitle,btn1,btn2,detbtn)
        switch answer
            case 'YES'
                for j = 1:size(d,2)
                    foo = d(:,j);
                    if ~isempty(foo<0)
                        d(:,j) = foo + abs(min(foo));
                        foo = d(:,j);
                    end
                    if ~isempty(foo == 0)
                        d(:,j) = foo + min(foo(foo > 0));
                    end
                end
        end
    end
    
    dm = mean(abs(d),1);
    nTpts = size(d,1);
    dod(ii).SetTime(intensity(ii).GetTime());
    dod(ii).SetDataTimeSeries(-log(abs(d)./(ones(nTpts,1)*dm)));
    dod(ii).SetMl(intensity(ii).GetMl());
    dod(ii).SetDataTypeDod();
end
