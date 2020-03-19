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

for k = 1 : length(theFilesControl)
    
    baseFileNameControl = theFilesControl(k).name;
    fullFileNameControl = fullfile(myControlFolder, baseFileNameControl);
    dataControl = readtable(fullFileNameControl);
    
    baseFileNameParkinsons = theFilesParkinsons(k).name;
    fullFileNameParkinsons = fullfile(myParkinsonsFolder, baseFileNameParkinsons);
    dataParkinsons = readtable(fullFileNameParkinsons);
    
    plotData(dataControl, dataParkinsons);
    
end



function plotData(dataControl, dataParkinsons)

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
    iterations = 100;
    euclydianDistanceControl = zeros(iterations,1);
    euclydianDistanceParkinsons = zeros(iterations,1);

    %used to change xlimits for smoother looking animated plot
    xLimIncrement = iterations/(iterations/100);

    %fixing figure window size
    set(gcf, 'Position',  [25, 25, 1200, 1900]);
    xlim([0 xLimIncrement]);
    ylim([0 5]);

    ylabel("Distance between Finger and Thumb");
    xlabel("Frame Number")

    grid on;

    trendControl = animatedline('Color', 'b', 'LineWidth', 2.0);
    trendParkinsons = animatedline('Color', 'r', 'LineWidth', 2.0);

    accumulatedDistanceControl = 0;
    accumulatedDistanceParkinsons = 0;

    legend('Control Type', 'Parkinsonian Type', 'FontSize', 14);

    for k = 1 : iterations
        euclydianDistanceControl(k, 1) = norm(controlThumbPositions(k,3) - controlIndexPositions(k,3)) - min(euclydianDistanceControl);
        
        accumulatedDistanceControl = accumulatedDistanceControl + euclydianDistanceControl(k,1);
        addpoints(trendControl, k, (euclydianDistanceControl(k)));

        euclydianDistanceParkinsons(k,1) = norm(parkinsonsThumbPositions(k,3) - parkinsonsIndexPositions(k,3)) - min(euclydianDistanceParkinsons);
        accumulatedDistanceParkinsons = accumulatedDistanceParkinsons + euclydianDistanceParkinsons(k,1);
        addpoints(trendParkinsons, k, (euclydianDistanceParkinsons(k)));
        TF = islocalmin
        plot(k(TF), trendControl(TF), trendParkinsons(TF),'r*')
        drawnow
        
        if(mod(k,101) == 0)
            xLimIncrement = xLimIncrement + 100;
            xlim([0 xLimIncrement]);
            clearpoints(trendControl);
            clearpoints(trendParkinsons);
        end
        
        

    end
    clf;
    fprintf('total distance travelled by parkinson subject: %f \n', accumulatedDistanceParkinsons);
    fprintf('total distance travelled by control subject: %f \n', accumulatedDistanceControl);
    

end