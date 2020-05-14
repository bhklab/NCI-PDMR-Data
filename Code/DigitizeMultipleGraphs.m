%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Authors: Denis Keimakh & Blake Jones
%
% Script designed to iterate through a folder containing images of graphs
% digitizing the data contained in each one. For each desired graph, the
% user will get to see the points that have been recognized and manually
% add any that have been missed. The digitized data will be saved as a csv
% in the directory of the user's choice.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------- User Prompt --------------------------------%
% Prompt user to enter path to folder containing graph images
prompt = {'Enter .jpg File Location', 'Enter CSV Save File Location', 'Enter File Number To Start Analysis'};
dialogue = 'Graph Digitizer';
dims = [1 35];
definput = {'C:\', 'C:\', '1'};
wd = inputdlg(prompt,dialogue,dims,definput);
% Folder containing the graphs
graphFolder = wd{1};
% Folder to save results to
saveFolder = wd{2};
% Allows the user to indicate which graph image they would like to start at
% given the images are sorted in alphabetical order
numToStart = str2double(wd{3});
%-------------------------------------------------------------------------%

% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(graphFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', graphFolder);
    uiwait(warndlg(errorMessage));
    return;
end

% --------------------------- User Prompt --------------------------------%
[xTitle, yTitle, pointArea, intensityThr, imageBorder] = GetGraphParameters();
%-------------------------------------------------------------------------%

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(graphFolder, '*.jpg');
fileList = dir(filePattern);
numFiles = length(fileList);

%Perform an analysis of each .jpg file individually
k = numToStart;
while (k < numFiles)
       
    % Load the current graph image
    baseFileName = fileList(k).name;
    fullFileName = fullfile(graphFolder, baseFileName);
    fprintf(1, 'Now reading file # %d / %d: %s\n', k, numFiles, fullFileName);
    
    % Check if the user wants to proceed with the existing symbol
    % parameters or choose new ones.
    if (k == numToStart)
        % Create question dialog
        answer = questdlg(sprintf("Proceed with symbol parameters: \n Point Area: " ...
            + num2str(pointArea) + " \n Intensity Threshold: " ...
            + num2str(intensityThr)), "Graph Digitizer", "Yes", ...
            "Choose new parameters", "Yes");
        % Handle response, yes continues
        switch answer
            case "Yes"
                % Continue with digitization
            case "Choose new parameters"
                [pointArea, intensityThr, imageBorder] = GetSymbolParameters(imread(fullFileName));
        end
    end
    
    % Digitize the graph
    [redo, newParams, pointArea, intensityThr, imageBorder, sortedData] = ...
        DigitizeGraph(fullFileName, pointArea, intensityThr, imageBorder);
    
    % Handle flags
    % Redo the current graph 
    if (redo)
        continue;
    else
        % Increment k to point to next graph
        k = k + 1;
    end
    
    %--------------------- Save Digitized Data ---------------------------%
    % Convert array to table and label the columns
    T = array2table(sortedData,'VariableNames',{xTitle,yTitle});
    
    % Get the name of the graph file to use as the name of the save file
    graphName = split(baseFileName, ".");
    graphName = graphName{1};
    dataExt = '.csv';
    saveFile = strcat(graphName(1),dataExt);
    
    csvFileName = [saveFolder filesep saveFile];
    
    % This will title the CSV files appropriately
    writetable(T, csvFileName);
    fprintf(1, 'Now saving %s\n', csvFileName);
    %---------------------------------------------------------------------%
    
end