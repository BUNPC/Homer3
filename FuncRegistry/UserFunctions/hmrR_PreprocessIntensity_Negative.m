% SYNTAX:
% intensity = hmrR_PreprocessIntensity_Negative( intensity )
%
% UI NAME:
% hmrR_PreprocessIntensity_Negative
%
% DESCRIPTION:
% Fix negative values in intensity by either adding an offset to make all
% numbers positive (+eps)(option 1) or just set values <=0 to +eps (option
% 2)
%
% INPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% OUTPUT:
% intensity - SNIRF data type where the d matrix is intensity
%
% USAGE OPTIONS:
% Intensity_to_Intensity: d = hmrR_PreprocessIntensity_Negative(data)
%
function d = hmrR_PreprocessIntensity_Negative( intensity )


for ii=1:length(intensity)
    d = intensity(ii).GetDataTimeSeries();
    lst = find(d(:)<=0);
    if ~isempty(lst)
        quest = {'Intensity signal has negative values.'};
        dlgtitle = 'Warning';
        btn1 = 'OPTION1: Add a dc offset';
        btn2 = 'OPTION2: Set values <=0 to eps';
        btn3 = 'CANCEL';
        detbtn = btn3;
        answer = questdlg(quest,dlgtitle,btn1,btn2,btn3, detbtn);
        switch answer  
            case 'OPTION1: Add a dc offset'
                for j = 1:size(d,2)
                    foo = d(:,j);
                    if ~isempty(find(foo<=0))
                        d(:,j) = foo + abs(min(foo)) + eps;
                    end
                end
            case 'OPTION2: Set values <=0 to eps'
                for j = 1:size(d,2)
                    foo = d(:,j);
                    if ~isempty(find(foo<=0))
                        d(find(foo<=0),j) = eps;
                    end
                end
        end
    end
    intensity(ii).SetDataTimeSeries(d);
end
