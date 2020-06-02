% Plots the distance between the finger and thumb for a MDS-UPDRS test
% ref: https://www.movementdisorders.org/MDS/MDS-Rating-Scales/MDS-Unified-Parkinsons-Disease-Rating-Scale-MDS-UPDRS.htm
%  useful for visually identifying key
% characteristics such as hesitations, and slowing of movements. 

%---------------------- boilerplate MATLAB batch processing ---------------
myControlFolder = './exampleplotdata/control/';
myParkinsonsFolder = './exampleplotdata/parkinsons/';                                                 
    
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


% number of frames being analysed
iterations = 1500;
figure;

%-----------------------iterate over each CSV file---------------------------------------
for k = 1 : length(theFilesControl)
    
    baseFileNameControl = theFilesControl(k).name;
    fullFileNameControl = fullfile(myControlFolder, baseFileNameControl);
    dataControl = readtable(fullFileNameControl);
    
    baseFileNameParkinsons = theFilesParkinsons(k).name;
    fullFileNameParkinsons = fullfile(myParkinsonsFolder, baseFileNameParkinsons);
    dataParkinsons = readtable(fullFileNameParkinsons);
    
    plotData(dataControl, dataParkinsons, iterations);
    
    %makes sure only the necessary figure windows open
    if k+1 <= length(theFilesControl)
        figure(k+1);
    end
    
end
%-------------------------end of file--------------------------------------


%------function plots csv data on seperate figure for each file------------
function plotData(dataControl, dataParkinsons, iterations)
    
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
  
    %fixing figure window size
    set(gcf, 'Position',  [15, 15, 1500, 950]);
    
    
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
    
    clf;   
    
   
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
    
    
    % loops applying the normalisation process
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
    
    %[normaliseControl maxControl normaliseParkinsons  maxParkinsons]
    
    %used for frame data plot
    x = 1:iterations;
    
    plot(x, control, 'LineWidth', 2, 'color', 'r')
    hold on
    plot(x, parkinsons, 'LineWidth', 2, 'color', 'b');
    plot(x(TF1), control(TF1), 'r*', 'LineWidth', 2', 'color', 'g');
    plot(x(TF2), parkinsons(TF2), 'r*', 'LineWidth', 2', 'color', 'g');
    
    plot(x(TF3), control(TF3), 'r*', 'LineWidth', 2', 'color', 'c');
    plot(x(TF4), parkinsons(TF4), 'r*', 'LineWidth', 2', 'color', 'c');
    
    %plotting the lines of best fit for min/max values
    p1 = polyfit(x(TF4), parkinsons(TF4), 1);
    f1 = polyval(p1, x(TF4));

    %plot(x(TF4), f1, '--r', 'color', 'k', 'LineWidth', 2.0);
    p2 = polyfit(x(TF2), parkinsons(TF2), 1);
    f2 = polyval(p2, x(TF2));
    %plot(x(TF2), f2, '--r', 'color', 'k', 'LineWidth', 2.0);
      
%     plot titles and labels
    title("$\textbf{\emph Displacement of Finger and Thumb as a function of time (" + iterations + " frames at 70fps)}$", 'Interpreter','latex', 'FontSize', 20, 'fontweight', 'bold');
    ylabel('$\textbf{\emph Z-Axis displacement from \newline starting position}$', 'fontweight', 'bold', 'fontsize', 16, 'Interpreter','latex');
    xlabel('$\textbf{\emph Frame Number}$', 'fontweight' ,'bold', 'fontsize', 16, 'Interpreter','latex');
%     defining axis boundaries
    ylim([0 1.5]);
    xlim([0 200]);
    legend('$\textbf{\emph Control Type}$', '$\textbf{\emph Parkinsonian Type}$', 'FontSize', 14, 'Interpreter','latex', 'fontweight', 'bold');
    grid on;
    
    %rotating x array to a x*1 array instead of 1*x
    xRot = rot90(x);
    
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
    ControlSpeed = (control(TF3)-control(TF1))./(xRot(TF3)-xRot(TF1));
    ParkinsonsSpeed = (parkinsons(TF4)-parkinsons(TF2))./(xRot(TF4)-xRot(TF2));
         
    
    
    
    
    % calculating frequency
    % 1 frame = 1/70 = 0.0142s. 
    wt_minimas = sum(TF1(:) == 1);
    pt_minimas = sum(TF2(:) == 1);
    
    time = iterations * 0.0142;
    
    wt_frequency = (wt_minimas)/(time);
    pt_frequency = (pt_minimas)/(time);
    
%     identifies hesitations
    [wt_hesitations, pt_hesitations] = identify_hesitations(control,parkinsons, TF1, TF2, TF3, TF4);
    

    % getting the average speed, ignoring sign
    AverageControlSpeed = abs(mean(ControlSpeed));
    AverageParkinsonsSpeed = abs(mean(ParkinsonsSpeed));
    
    txt1 = ['$\textbf{\emph Control Type Speed: ' num2str(AverageControlSpeed) '}$'];
    txt2 = ['$\textbf{\emph Parkinsonian Type Speed: ' num2str(AverageParkinsonsSpeed) '}$'];
    txt3 = ['$\textbf{\emph Control Frequency: ' num2str(wt_frequency) '}$'];
    txt4 = ['$\textbf{\emph Parkinsonian Frequency: ' num2str(pt_frequency) '}$'];
    txt5 = ['$\textbf{\emph Control Distance Travelled: ' num2str(accumulatedDistanceControl) '}$'];
    txt6 = ['$\textbf{\emph Parkinsonian Distance Travelled: ' num2str(accumulatedDistanceParkinsons) '}$'];
    txt7 = ['$\textbf{\emph Control Hesitations: ' num2str(wt_hesitations) '}$'];
    txt8 = ['$\textbf{\emph Parkinson Hesitations: ' num2str(pt_hesitations) '}$'];
    
    
    
    %defining text at top left of figure
    ylimits = ylim;
    ymax = ylimits(2);
    vert_spacing = ymax/47;  %arbitrary positioning of text
         
%     prints the calculated results to the plot
    text(8, ymax-vert_spacing*1, txt1, 'Interpreter','latex');
    text(8, ymax-vert_spacing*2, txt2, 'Interpreter','latex');
    text(8, ymax-vert_spacing*3, txt3, 'Interpreter','latex');
    text(8, ymax-vert_spacing*4, txt4, 'Interpreter','latex');
    text(8, ymax-vert_spacing*5, txt5, 'Interpreter','latex');
    text(8, ymax-vert_spacing*6, txt6, 'Interpreter','latex');
    text(8, ymax-vert_spacing*7, txt7, 'Interpreter','latex');
    text(8, ymax-vert_spacing*8, txt8, 'Interpreter','latex');
    
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





% old function no longer useful. more efficient way of calculating speed
function getSpeed(control, parkinsons, TF1, TF2, TF3, TF4)

    % minFrameNum = [1], maxFrameNum = [2], minPos = [3], maxPos = [4].
    controlDetails = [0 0 0 0];
    parkinsonsDetails = [0 0 0 0];
    
    % speed = distance/time. 
 
    for i = 1: length(control)
       if TF1(i) == 1 
           controlDetails(1,1) = i;
           controlDetails(1,3) = control(i,1);
       elseif TF3(i) == 1
           controlDetails(1,2) = i;
           controlDetails(1,4) = control(i,1);
       end
    end
    
    for i = 1: length(parkinsons)
       if TF2(i) == 1 
           parkinsonsDetails(1,1) = i;
           parkinsonsDetails(1,3) = parkinsons(i,1);
       elseif TF4(i) == 1
           parkinsonsDetails(1,2) = i;
           parkinsonsDetails(1,4) = parkinsons(i,1);
       end
    end
    
    distanceTravelled = [0 0];
    timeFrame = [0 0];
    timeElapsed = [0 0];
    speed = [0 0];
    
    
    distanceTravelled(1,1) = sqrt(( controlDetails(1,2) - controlDetails(1,1) ).^2 + ( controlDetails(1,4) - controlDetails(1,3) ).^2);
    distanceTravelled(1,2) = sqrt(( parkinsonsDetails(1,2) - parkinsonsDetails(1,1) ).^2 + ( parkinsonsDetails(1,4) - parkinsonsDetails(1,3) ).^2);
    
    timeFrame(1,1) = controlDetails(1,4) - controlDetails(1,3);
    timeFrame(1,2) = parkinsonsDetails(1,4) - parkinsonsDetails(1,3);
    
    timeElapsed(1,1) = timeFrame(1,1) * 0.0142;
    timeElapsed(1,2) = timeFrame(1,2) * 0.0142;
    %recorded at 70fps, so each frame = 1/70 seconds = 0.0142s. 
    
    speed(1,1) = distanceTravelled(1,1) / timeElapsed(1,1);
    
end



