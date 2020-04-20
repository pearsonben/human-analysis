
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


% CHANGING VALUE WILL AMEND AMOUNT OF FRAMES ANALYSED OF EACH FILE
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
    
    control_amplitude = abs(control(TF3) - control(TF1));
    parkinsons_amplitude = abs(parkinsons(TF4) - parkinsons(TF2));
    
    x1 = rot90(1:length(control_amplitude));
    x2 = rot90(1:length(parkinsons_amplitude));
    
    p1 = polyfit(x1, control_amplitude,1);
    f1 = polyval(p1,x1);
    
    p2 = polyfit(x2, parkinsons_amplitude,1);
    f2 = polyval(p2,x2);
    
    
%     plot(x1, control_amplitude, 'r*', 'LineWidth', 2', 'color', 'r');
%     hold on;
    plot(x2, parkinsons_amplitude, 'r*', 'LineWidth', 2', 'color', 'b');
    grid on;
    hold on;
    plot(x2, f2, '--r', 'LineWidth', 2.0, 'color', 'r');
%     plot(x1, f1, '--r', 'LineWidth', 2.0, 'color', 'b');
    
    title("$\textbf{\emph Amplitude Regression over time for MDS UPDRS test, for  (" + iterations + " frames at 70fps)}$", 'Interpreter','latex', 'FontSize', 20, 'fontweight', 'bold');
    ylabel('$\textbf{\emph Amplitude (units)}$', 'fontweight', 'bold', 'fontsize', 16, 'Interpreter','latex');
    xlabel('$\textbf{\emph Movement Cycle}$', 'fontweight' ,'bold', 'fontsize', 16, 'Interpreter','latex');
    legend('$\textbf{\emph Amplitude (Parkinsons)}$', '$\textbf{\emph Regression Line}$', 'FontSize', 14, 'Interpreter','latex', 'fontweight', 'bold');
    
    
    
%     ylim([0 0.1]);
%     xlim([0 50]);
    
end






