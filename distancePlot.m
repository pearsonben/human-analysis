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

legend('Control Type', 'Parkinsonian Type', 'FontSize', 14);

for k = 1 : length(theFilesControl)
    
    baseFileNameControl = theFilesControl(k).name;
    fullFileNameControl = fullfile(myControlFolder, baseFileNameControl);
    dataControl = readtable(fullFileNameControl);
    
    baseFileNameParkinsons = theFilesParkinsons(k).name;
    fullFileNameParkinsons = fullfile(myParkinsonsFolder, baseFileNameParkinsons);
    dataParkinsons = readtable(fullFileNameParkinsons);
    
    plotData(dataControl, dataParkinsons, k);
    
end



function plotData(dataControl, dataParkinsons, figurenum)

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
    iterations = 300;
    euclydianDistanceControl = zeros(iterations,1);
    euclydianDistanceParkinsons = zeros(iterations,1);

    %used to change xlimits for smoother looking animated plot
    xLimIncrement = iterations/(iterations/100);

    %fixing figure window size
    set(gcf, 'Position',  [25, 25, 1200, 800]);
    xlim([0 xLimIncrement]);
    ylim([0 5]);

    ylabel("Distance between Finger and Thumb");
    xlabel("Frame Number")

    grid on;

    accumulatedDistanceControl = 0;
    accumulatedDistanceParkinsons = 0;

   

    for k = 1 : iterations
        euclydianDistanceControl(k, 1) = norm(controlThumbPositions(k,3) - controlIndexPositions(k,3)) - min(euclydianDistanceControl);   
        accumulatedDistanceControl = accumulatedDistanceControl + euclydianDistanceControl(k,1);
        euclydianDistanceParkinsons(k,1) = norm(parkinsonsThumbPositions(k,3) - parkinsonsIndexPositions(k,3)) - min(euclydianDistanceParkinsons);
        
        if(islocalmin(euclydianDistanceControl(k, 1)) == 1)
            fprintf("hello!");
        end
        
        if(islocalmin(euclydianDistanceParkinsons(k, 1)) == 1)
            euclydianDistanceParkinsons(iterations, 1)
        end
        
        accumulatedDistanceParkinsons = accumulatedDistanceParkinsons + euclydianDistanceParkinsons(k,1);
        if(mod(k,101) == 0)
            xLimIncrement = xLimIncrement + 100;
            xlim([0 xLimIncrement]);
        end
    end
    
    clf;
    %fprintf('total distance travelled by parkinson subject: %f \n', accumulatedDistanceParkinsons);
    %fprintf('total distance travelled by control subject: %f \n', accumulatedDistanceControl);
    
    TF1 = islocalmin(euclydianDistanceControl(1:iterations,1));
    TF2 = islocalmin(euclydianDistanceParkinsons(1:iterations,1));
    TF3 = islocalmax(euclydianDistanceControl(1:iterations,1));
    TF4 = islocalmax(euclydianDistanceParkinsons(1:iterations,1));
     
    
    control = euclydianDistanceControl(1:iterations,1);
    parkinsons = euclydianDistanceParkinsons(1:iterations,1);
    
    x = 1:iterations;
    
    plot(x, control, 'LineWidth', 2, 'color', 'r')
    hold on
    plot(x(TF1), control(TF1), 'r*', 'LineWidth', 2', 'color', 'g');
    plot(x(TF2), parkinsons(TF2), 'r*', 'LineWidth', 2', 'color', 'g');
    plot(x(TF3), control(TF3), 'r*', 'LineWidth', 2', 'color', 'c');
    plot(x(TF4), parkinsons(TF4), 'r*', 'LineWidth', 2', 'color', 'c');
    plot(x, parkinsons, 'LineWidth', 2, 'color', 'b')
    
    %[control TF1 control TF3]
    
    getSpeed(control, TF1, TF3)
    figure(figurenum)

end


function getSpeed(control, TF1, TF3)
    
    minFrameNum = 0;
    maxFrameNum = 0;
    minPos = 0;
    maxPos = 0;
    % trying to figure out how to calculate the speed. need frame number,
    % speed = distance/time. 
    % 
    for i = 1: length(control)
       if TF1(i) == 1 
           minFrameNum = i;
           minPos = control(i,1);
       elseif TF3(i) == 1
           maxFrameNum = i;
           maxPos = control(i,1);
       end
    end
    
    distanceTravelled = sqrt(( maxFrameNum - minFrameNum ).^2 + ( maxPos - minPos ).^2);
    timeFrame = maxPos - minPos;
    timeElapsed = timeFrame * 0.0142;
    %recorded at 70fps, so each frame = 1/70 seconds = 0.0142s. 
    
    speed = distanceTravelled / timeElapsed
    
    
    
end