function [xTitle, yTitle, pointArea, intensityThr, imageBorder] = GetGraphParameters()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Helper function to get the required graph parameters prior to
% digitization.
%
% Output:
%   - xTitle: desired title of the X-axis
%   - yTitle: desired title of the Y-axis
%   - pointArea: As defined in GetSymbolParameters
%   - intensityThr: As defined in GetSymbolParameters
%   - imageBorder: As defined in GetSymbolParameters
%
% Authors: Denis Keimakh & Blake Jones
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------- User Prompt --------------------------------%
% Prompt the user to enter the area of a point-symbol on the graph, the ,
% and the titles for the X and Y axes.
prompt  = {'Point Area','Pixel Index', 'Enter X-Axis Title', 'Enter Y-Axis Title'};
what = 'Values?';
dims = [1 35];
definput = {'2','5','Study_days','Tumor_volume_mm3'};
graphParameters = inputdlg(prompt,what,dims,definput);

xTitle = graphParameters{3};
yTitle = graphParameters{4};

% This is graph type specific, depends on area of point defined by the
% pixel editor - change this per group - should explain
pointArea = str2double(graphParameters{1});
% this changes based on the data point "look" - should explain
intensityThr = str2double(graphParameters{2});
imageBorder = pointArea + 1;
%-------------------------------------------------------------------------%

end