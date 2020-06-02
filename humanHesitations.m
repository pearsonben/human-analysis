
%---------------------- boilerplate MATLAB batch processing ---------------
myControlFolder = './data/control/';
myParkinsonsFolder = './data/parkinsons/';                                                 
    
%checking for valid filepath
if ~isfolder(myControlFolder)
    errorMessage=sprintf('Error: The following folder does not exist:\n%s', myWTFolder);
    uiwait(warndlg(errorMessage));
    return;
end

if ~isfolder(myParkinsonsFolder)
    errorMessage=sprintf('Error: The following folder does not exist:\n%s', myPTFolder);
    uiwait(warndlg(errorMessage));
    return;
end

filePatternControl = fullfile(myControlFolder, '*.csv');
theFilesControl = dir(filePatternControl);

filePatternParkinsons = fullfile(myParkinsonsFolder, '*.csv');
theFilesParkinsons = dir(filePatternParkinsons);

%-----------------------------------end of boilerplate----------------------------


% CHANGING VALUE WILL AMEND AMOUNT OF FRAMES ANALYSED OF EACH FILE
iterations = 1500;

gradients = zeros(length(theFilesControl), 2);

%-----------------------iterate over each CSV file---------------------------------------
for k = 1 : length(theFilesControl)
    
    baseFileNameControl = theFilesControl(k).name;
    fullFileNameControl = fullfile(myControlFolder, baseFileNameControl);
    dataControl = readtable(fullFileNameControl);
    
    baseFileNameParkinsons = theFilesParkinsons(k).name;
    fullFileNameParkinsons = fullfile(myParkinsonsFolder, baseFileNameParkinsons);
    dataParkinsons = readtable(fullFileNameParkinsons);
    
    val = plotData(dataControl, dataParkinsons, iterations);
    gradients(k, 1) = val(1);
    gradients(k, 2) = val(2);
    
end

avg_wt_hesitations = mean(gradients(1:end,1));
avg_pt_hesitations = mean(gradients(1:end,2));


fprintf('Average number of control hesitations: %.0f\t', avg_wt_hesitations);
fprintf('Average number of PD hesitations: %.0f\n', avg_pt_hesitations);

% gradients



%-------------------------end of file--------------------------------------

%------function plots csv data on seperate figure for each file------------
function gradients = plotData(dataControl, dataParkinsons, iterations)
    
    %splitting the csv file into two, extracting every other line
    parkinsonsThumb = dataParkinsons(1:2:end,:);
    parkinsonsIndex = dataParkinsons(2:2:end,:);
    controlThumb = dataControl(1:2:end,:);
    controlIndex = dataControl(2:2:end,:);
    
    % storing co-ordinate components for both Parkinsons and Control type
    
    %control thumb data
    xCT = controlThumb{1:end, 2};
    yCT = controlThumb{1:end, 3};
    zCT = controlThumb{1:end, 4};
    %control index finger data
    xCI = controlIndex{1:end, 2};
    yCI = controlIndex{1:end, 3};
    zCI = controlIndex{1:end, 4};
    %parkinsonian thumb data
    xPT = parkinsonsThumb{1:end, 2};
    yPT = parkinsonsThumb{1:end, 3};
    zPT = parkinsonsThumb{1:end, 4};
    %parkinsonian index finger data
    xPI = parkinsonsIndex{1:end, 2};
    yPI = parkinsonsIndex{1:end, 3};
    zPI = parkinsonsIndex{1:end, 4};
    
    %storing co-ordinates in arrays for readability
    controlThumbPositions = [xCT yCT zCT];
    controlIndexPositions = [xCI yCI zCI];
    parkinsonsThumbPositions = [xPT yPT zPT];
    parkinsonsIndexPositions = [xPI yPI zPI];
    
    %defining empty array, will contain list of distances between finger and thumb 
    euclydianDistanceControl = zeros(iterations,1);
    euclydianDistanceParkinsons = zeros(iterations,1);
   
    accumulatedDistanceControl = 0;
    accumulatedDistanceParkinsons = 0;

    for k = 1 : iterations
        % calculating and storing the distance between index and thumb for
        % each frame
        euclydianDistanceControl(k, 1) = abs(controlThumbPositions(k,3) - controlIndexPositions(k,3));   
        euclydianDistanceParkinsons(k,1) = abs((parkinsonsThumbPositions(k,3)) - parkinsonsIndexPositions(k,3));
        % summing the total travelled distance
        accumulatedDistanceControl = accumulatedDistanceControl + euclydianDistanceControl(k,1);
        accumulatedDistanceParkinsons = accumulatedDistanceParkinsons + euclydianDistanceParkinsons(k,1);
  
    end
    
    %clf;   
    
    control = euclydianDistanceControl(1:iterations,1);
    parkinsons = euclydianDistanceParkinsons(1:iterations,1);
    
    %storing all local minimas and maxima. 0 = no local min/max, 1 = local
    %min/max
    TF1 = islocalmin(control);
    TF2 = islocalmin(parkinsons);
    TF3 = islocalmax(control);
    TF4 = islocalmax(parkinsons);
 
    %normalising the data for side-by-side comparisons
    normaliseControl = min(control(TF1));
    normaliseParkinsons = min(parkinsons(TF2));
    
    % loops applying the normalisation
    for k = 1 : length(control)  
        control(k) = (control(k) -  normaliseControl);
    end
  
    for k = 1 : length(parkinsons)        
        parkinsons(k) = (parkinsons(k) -  normaliseParkinsons);
    end
    
    maxControl = max(control(TF3));
    maxParkinsons = max(parkinsons(TF4));
    
    for k = 1 : length(control)  
        control(k) = control(k)/maxControl;
    end
  
    for k = 1 : length(parkinsons)        
        parkinsons(k) = parkinsons(k)/maxParkinsons;
    end
    
    %used for frame data plot
    x = 1:iterations;
    
    % getting last non-zero value of the TF arrays.
    lastTF1 = find(TF1,1,'last');
    lastTF2 = find(TF2,1,'last');
    lastTF3 = find(TF3,1,'last');
    lastTF4 = find(TF4,1,'last');
    
    % if matrix sizes are mismatched, remove the last non-zero element to
    % make them evenly lengthed.theres probably a better way of doing this 
    if length(control(TF3)) > length(control(TF1))
        TF3(lastTF3) = [];
    elseif length(control(TF3)) < length(control(TF1))
        TF1(lastTF1) = [];
    end
    
    if length(parkinsons(TF4)) > length(parkinsons(TF2))
        TF4(lastTF4) = [];
    elseif length(parkinsons(TF4)) < length(parkinsons(TF2))
        TF2(lastTF2) = [];
    end
    
    %calculating the gradient of the slope between each maxima and minima
    
    control_amplitude = abs(control(TF3) - control(TF1));
    parkinsons_amplitude = abs(parkinsons(TF4) - parkinsons(TF2));
    
    x1 = rot90(1:length(control_amplitude));
    x2 = rot90(1:length(parkinsons_amplitude));
    
    p1 = polyfit(x1, control_amplitude,1);
    p2 = polyfit(x2, parkinsons_amplitude,1);

    wt_gradient = p1(1);
    pt_gradient = p2(1);
    
    [wt_hesitations, pt_hesitations] = identify_hesitations(control,parkinsons, TF1, TF2, TF3, TF4);
    
    
    gradients = [wt_hesitations pt_hesitations];
    
end


% function counts the total number of hesitations for each type, then
% returns an array with the value each type
function [wt_hesitation_counter, pt_hesitation_counter] = identify_hesitations(control, parkinsons, TF1, TF2, TF3, TF4)

    wt_mins = control(TF1);
    wt_maxs = control(TF3);
    pt_mins = parkinsons(TF2);
    pt_maxs = parkinsons(TF4);
    
    wt_hesitation_counter = 0;
    pt_hesitation_counter = 0;
    for i = 1 : size(wt_mins)
       %arbitrary -+ 0.25 to identify if a maxima is too close to a minima,
       %seeing if theres a hesitation
       if (wt_maxs(i) <= wt_mins(i) + 0.25) || (wt_mins(i) >=  wt_maxs(i) - 0.25)
            wt_hesitation_counter = wt_hesitation_counter + 1;

       end
    end
    
    for i = 1 : size(pt_mins)
        
        if (pt_maxs(i) <= pt_mins(i) + 0.25) || (pt_mins(i) >=  pt_maxs(i) - 0.25)
            pt_hesitation_counter = pt_hesitation_counter + 1;

        end

    end
end



