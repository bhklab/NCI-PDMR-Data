function [pointArea, intensityThr, imageBorder] = GetSymbolParameters(imageArray)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Helper function to allow the user to select a graph marker and then 
% calculate the marker area and intensity for point segmentation.
%
% Input:
%   - imageArray: image read by imread
%
% Output:
%   - pointArea: number of pixels to consider above and below, left and
%   right of the central pixel when looking for points.
%   - intensityThr: mean value below which indicates a point has been found
%   - imageBorder: integer currently calculated as pointArea + 1, used to
%   avoid borders.
%
% Authors: Denis Keimakh & Blake Jones
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert to gray scale and plot the graph
graph = rgb2gray(imageArray);
imagesc(graph), axis image, colormap(gray), set(gcf, 'Position', ...
    get(0, 'Screensize')),
title('Click or scroll to zoom, then press Enter to draw a rectangle over a point marker, then press Enter'); 
hold on
% Set the zoom mode to be active
zoom on

% Wait for the most recent key to become the return/enter key
waitfor(gcf, 'CurrentCharacter', char(13))
zoom reset
zoom off

% Allow the user to select a point using a rectangular region and create a
% binary mask for that point.
point = drawrectangle('Label','Point Marker');
pointMask = createMask(point,imageArray);

% Set the point area as the minimum dimension of the rectangle selected by
% the user, but limit it to a minimum value of 2.
pointArea = floor(min(sum(any(pointMask,1)), sum(any(pointMask,2))) / 2) - 1;
pointArea = max(pointArea,2);

% Calculate the intensity threshold as the mean of all the pixels in the
% selected region.
intensityThr = mean(imageArray(pointMask), 'all');

imageBorder = pointArea + 1;

% Close the figure containing the point selector
close
end