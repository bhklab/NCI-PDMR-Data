function [redo, newParams, pointArea, intensityThr, imageBorder, sortedData] = DigitizeGraph(filename, pointArea, intensityThr, imageBorder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function to digitize an image of a graph. The user will get to see the
% points that have been recognized and manually add any that have been
% missed.
%
% Input:
%   - filename: full file path to the image of a graph
%   - pointArea: As defined in GetSymbolParameters
%   - intensityThr: As defined in GetSymbolParameters
%   - imageBorder: As defined in GetSymbolParameters
%
% Output:
%   - sortedData: A 2-d array where each row is a digitized point and the
%   first column is the x-coordinate and the second, the y-coordinate. Data
%   is sorted in ascending order based on x-coordinates.
%
% Authors: Denis Keimakh & Blake Jones
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return flags for when the user desires to redo the current graph with or
% without new symbol parameters.
redo = false;
newParams = false;

% Load graph image
imageArray = imread(filename);

% Convert to gray scale and plot the graph
graph = rgb2gray(imageArray);
imagesc(graph), axis image, colormap(gray), set(gcf, 'Position', ...
    get(0, 'Screensize')), set(gcf,'name',filename,'NumberTitle','off'),
title('Select the origin and maximum axis limits');
hold on

%---------------------------- User Prompt ----------------------------%
% Select origin, then top right corner
[x_pix,y_pix] = ginput(2);
plot(x_pix,y_pix,'rs--',...
    'LineWidth',2,...
    'MarkerSize',8,...
    'MarkerFaceColor',[1 0 0])
%----------------------------------------------------------------------%

%---------------------------- User Prompt ----------------------------%
% Prompt the user to enter in the axes limits, start and stop separated
% by a space.
prompt = {'Enter X Min:','Enter X Max:','Enter Y Min:','Enter Y Max:'};
ask = 'X and Y Range?';
dims = [1 25];
definput = {'','','',''};
answer = inputdlg(prompt,ask,dims,definput); % min and max should be seperated by a space right?

% Store the axes ranges. Each should contain two values (start and end)
xMin = str2double(answer{1});
xMax = str2double(answer{2});
yMin = str2double(answer{3});
yMax = str2double(answer{4});

% When the points have been clicked and the ranges have been entered,
% close the display figure
close
clear title
%---------------------------------------------------------------------%

% Empty list that will become our data points
data_points_pix = [];
for i = imageBorder:size(graph,1)- pointArea
    for j = imageBorder:size(graph,2)- pointArea
        % Check if the average intensity in the "point area" around pixel
        % (i,j) is under the intensity threshold for a point (i.e. more
        % black). If it is, add it to the point array
        if mean(graph(i-pointArea:i+pointArea,j-pointArea:j+pointArea), 'all') < intensityThr
            data_points_pix = [data_points_pix;j,i];
        end
    end
end

% Sorted data points
sorted_data_points_pix = (sortrows([data_points_pix]));

% Threshold that ensures the same point isn't counted twice
too_close = pointArea * 4;

% Find the points that were too close to another
pointsToRemove = zeros(size(sorted_data_points_pix,1),1);
for i = 1:size(sorted_data_points_pix,1)-1
    if pdist([sorted_data_points_pix(i,:); sorted_data_points_pix(i+1,:)]) < too_close
        pointsToRemove(i+1) = 1;
    end
end

% Remove too close points
sorted_data_points_pix(pointsToRemove == 1,:) = [];

% Check the number of points
numSortedPoints = size(sorted_data_points_pix,1);

%------------------- Check for missed points -------------------------%
% Change the current figure to display the original graph image
imshow(imageArray);set(gcf, 'Position', get(0, 'Screensize'))
title('Click missing data points, press enter to continue') 
hold on
% Plot the points found and the corresponding lines between them
if (numSortedPoints > 0)
    plot(sorted_data_points_pix(:,1),sorted_data_points_pix(:,2),'gs--',...
        'LineWidth',2,...
        'MarkerSize',8,...
        'MarkerFaceColor',[0 0 1])
end
% Get the x and y coordinates of the points to be added
[x_add,y_add] = ginputc('ShowPoints', true, 'ConnectPoints', false);
% Close the current figure
close
%---------------------------------------------------------------------%

% Group the x and y coordinates of the missed points
final_add = [x_add y_add];

% Add missed points to sorted points and resort
sorted_data_points_pix = [sorted_data_points_pix; final_add];
sorted_data_points_pix = (sortrows(sorted_data_points_pix));

%---------------------- Display final points -------------------------%
imshow(imageArray);set(gcf, 'Position', get(0, 'Screensize'));
hold on
% Check the number of points
if(size(sorted_data_points_pix,1) > 0)
    plot(sorted_data_points_pix(:,1),...
        sorted_data_points_pix(:,2),'gs-',...
        'LineWidth',2,...
        'MarkerSize',7,...
        'MarkerFaceColor',[1 1 0])
end
% Check if the user wants to proceed to saving the data
answer = questdlg("Proceed?", "Graph Digitizer",  "Yes", "Redo", "Redo with new symbol parameters", "Yes");

switch answer
    % Redo this graph
    case "Redo"
        redo = true;
        sortedData = [];
        return
        % Redo this graph but choose new symbol parameters first
    case "Redo with new symbol parameters"
        redo = true;
        newParams = true;
        [pointArea, intensityThr, imageBorder] = GetSymbolParameters(imageArray);
        sortedData = [];
        return
        
    case "Yes"
        % Proceed
end

% Calculate the total numerical ranges for the axes
totalXAxisRange = xMax - xMin;
totalYAxisRange = yMax - yMin;

% Calculate the length of the axes in pixels
numXPixels = x_pix(2) - x_pix(1);
numYPixels = y_pix(2) - y_pix(1);

% Calculate the in-graph values of each of the points using the total
% ranges of the two axes and the number of pixels in each dimension
% between the first and last points.
data_points = zeros(size(sorted_data_points_pix,1),2);
for i = 1:size(sorted_data_points_pix)
    
    data_points(i,:) = [(sorted_data_points_pix(i,1)-x_pix(1)) / numXPixels * totalXAxisRange + xMin,...
        (sorted_data_points_pix(i,2)-y_pix(1)) / numYPixels * totalYAxisRange + yMin];
    
end

% Sort the data points in ascending order based on their x-values
sortedData = sortrows(data_points); 

%------------------------ Final Display-------------------------------%
% Plot digitized data
subplot(1,2,1)
plot (sortedData(:,1), sortedData(:,2),'gs-',...
    'LineWidth',2,...
    'MarkerSize',7,...
    'MarkerFaceColor',[1 1 0])

% Display original graph image
subplot(1,2,2)
image(imageArray);set(gcf, 'Position', get(0, 'Screensize'))
hold on
sgt = sgtitle('Plotted Data Vs. Pixel Data','Color','black');
sgt.FontSize = 20;

% Wait for user to press a button and then close the figure
pause
close
%---------------------------------------------------------------------%
end