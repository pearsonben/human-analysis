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

% CHANGING VALUE WILL AMEND AMOUNT OF FRAMES ANALYSED OF EACH FILE
iterations = 300;

filePatternControl = fullfile(myControlFolder, '*.csv');
theFilesControl = dir(filePatternControl);

filePatternParkinsons = fullfile(myParkinsonsFolder, '*.csv');
theFilesParkinsons = dir(filePatternParkinsons);





for k = 1 : length(theFilesControl)
    
    baseFileNameControl = theFilesControl(k).name;
    fullFileNameControl = fullfile(myControlFolder, baseFileNameControl);
    dataControl = readtable(fullFileNameControl);
    
    baseFileNameParkinsons = theFilesParkinsons(k).name;
    fullFileNameParkinsons = fullfile(myParkinsonsFolder, baseFileNameParkinsons);
    dataParkinsons = readtable(fullFileNameParkinsons);
    
    plotData(dataControl, dataParkinsons, k, iterations);
    
end


function plotData(dataControl, dataParkinsons, figurenum, iterations)

    parkinsonsThumb = dataParkinsons(1:2:end,:);
    parkinsonsIndex = dataParkinsons(2:2:end,:);
    
    controlThumb = dataControl(1:2:end,:);
    controlIndex = dataControl(2:2:end,:);
    
    xCT = controlThumb{1:end, 2};
    yCT = controlThumb{1:end, 3};
    zCT = controlThumb{1:end, 4};

    xCI = controlIndex{1:end, 2};
    yCI = controlIndex{1:end, 3};
    zCI = controlIndex{1:end, 4};

    xPT = parkinsonsThumb{1:end, 2};
    yPT = parkinsonsThumb{1:end, 3};
    zPT = parkinsonsThumb{1:end, 4};

    xPI = parkinsonsIndex{1:end, 2};
    yPI = parkinsonsIndex{1:end, 3};
    zPI = parkinsonsIndex{1:end, 4};
    
    controlThumbPositions = [xCT yCT zCT];
    controlIndexPositions = [xCI yCI zCI];

    parkinsonsThumbPositions = [xPT yPT zPT];
    parkinsonsIndexPositions = [xPI yPI zPI];
    
        %euclydian distance between two co-ordinates in matlab
    
    euclydianDistanceControl = zeros(iterations,1);
    euclydianDistanceParkinsons = zeros(iterations,1);

    %used to change xlimits for smoother looking animated plot
    xLimIncrement = iterations/(iterations/100);

    %fixing figure window size
    set(gcf, 'Position',  [15, 15, 1500, 950]);
    xlim([0 xLimIncrement]);
    ylim([0 5]);

    


    

    accumulatedDistanceControl = 0;
    accumulatedDistanceParkinsons = 0;

    for k = 1 : iterations
        
        euclydianDistanceControl(k, 1) = norm(controlThumbPositions(k,3) - controlIndexPositions(k,3)) - min(euclydianDistanceControl);   
        accumulatedDistanceControl = accumulatedDistanceControl + euclydianDistanceControl(k,1);
        euclydianDistanceParkinsons(k,1) = norm(parkinsonsThumbPositions(k,3) - parkinsonsIndexPositions(k,3)) - min(euclydianDistanceParkinsons);
        accumulatedDistanceParkinsons = accumulatedDistanceParkinsons + euclydianDistanceParkinsons(k,1);
        
        if(mod(k,101) == 0)
            xLimIncrement = xLimIncrement + 100;
            xlim([0 xLimIncrement]);
        end
        
    end
    
    clf;
    %fprintf('total distance travelled by parkinson subject: %f \n', accumulatedDistanceParkinsons);
    %fprintf('total distance travelled by control subject: %f \n', accumulatedDistanceControl);
    
    control = euclydianDistanceControl(1:iterations,1);
    parkinsons = euclydianDistanceParkinsons(1:iterations,1);
    
    %storing all local minimas and maxima. 0 = no local min/max, 1 = local
    %min/max
    TF1 = islocalmin(control);
    TF2 = islocalmin(parkinsons);
    TF3 = islocalmax(control);
    TF4 = islocalmax(parkinsons);
 
    x = 1:iterations;
    
   
    plot(x, control, 'LineWidth', 2, 'color', 'r')
    hold on
    plot(x, parkinsons, 'LineWidth', 2, 'color', 'b');
    plot(x(TF1), control(TF1), 'r*', 'LineWidth', 2', 'color', 'g');
    plot(x(TF2), parkinsons(TF2), 'r*', 'LineWidth', 2', 'color', 'g');
    plot(x(TF3), control(TF3), 'r*', 'LineWidth', 2', 'color', 'c');
    plot(x(TF4), parkinsons(TF4), 'r*', 'LineWidth', 2', 'color', 'c');
    
    title("$\textbf{\emph Displacement of Finger and Thumb as a function of time (}$" + iterations + "$\textbf{\emph frames at 70fps)}$", 'Interpreter','latex', 'FontSize', 20, 'fontweight', 'bold');
    ylabel('$\textbf{\emph Z-Axis displacement from starting position}$', 'fontweight', 'bold', 'fontsize', 16, 'Interpreter','latex');
    xlabel('$\textbf{\emph Frame Number}$', 'fontweight' ,'bold', 'fontsize', 16, 'Interpreter','latex');
    ylim([0 7]);
    
    legend('$\textbf{\emph Control Type}$', 'Parkinsonian Type', 'FontSize', 14, 'Interpreter','latex', 'fontweight', 'bold');
    grid on;
    
    %rotating x array to a x*1 array instead of 1*x
    xRot = rot90(x);
    
    % getting last non-zero value of the TF arrays.
    lastTF1 = find(TF1,1,'last');
    lastTF2 = find(TF2,1,'last');
    lastTF3 = find(TF3,1,'last');
    lastTF4 = find(TF4,1,'last');
    
    % if matrix sizes are mismatched, remove the last non-zero element to
    % make them evenly lengthed
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
     
    % getting the average value, ignoring sign
    AverageControlSpeed = abs(mean(ControlSpeed));
    AverageParkinsonsSpeed = abs(mean(ParkinsonsSpeed));
    txt = ['Average Control Type Speed: ' num2str(AverageControlSpeed) 'x/frame'];
    text(0, 1, txt, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    AverageControlSpeed
    AverageParkinsonsSpeed
    figure(figurenum)

end


% old function no longer useful. more efficient way of calculating the
% speed
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

