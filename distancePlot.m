
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
iterations = 1000;
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
        
        euclydianDistanceControl(k, 1) = abs(controlThumbPositions(k,3) - controlIndexPositions(k,3));   
        euclydianDistanceParkinsons(k,1) = abs((parkinsonsThumbPositions(k,3)) - parkinsonsIndexPositions(k,3));
        
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
    
    % loops applying the normalisation
    for k = 1 : length(control)
        control(k) = control(k) -  normaliseControl;   
    end
  
    for k = 1 : length(parkinsons)  
        parkinsons(k) = parkinsons(k) -  normaliseParkinsons;      
    end
    
    %used for frame data plot
    x = 1:iterations;
    
    %plot(x, control, 'LineWidth', 2, 'color', 'r')
    hold on
    plot(x, parkinsons, 'LineWidth', 2, 'color', 'b');
    %plot(x(TF1), control(TF1), 'r*', 'LineWidth', 2', 'color', 'g');
    plot(x(TF2), parkinsons(TF2), 'r*', 'LineWidth', 2', 'color', 'g');
    
    %plot(x(TF3), control(TF3), 'r*', 'LineWidth', 2', 'color', 'c');
    plot(x(TF4), parkinsons(TF4), 'r*', 'LineWidth', 2', 'color', 'c');
    
    %plotting the lines of best fit for min/max values
    p1 = polyfit(x(TF4), parkinsons(TF4), 1);
    f1 = polyval(p1, x(TF4));

    plot(x(TF4), f1, '--r', 'color', 'k', 'LineWidth', 2.0);
    p2 = polyfit(x(TF2), parkinsons(TF2), 1);
    f2 = polyval(p2, x(TF2));
    plot(x(TF2), f2, '--r', 'color', 'k', 'LineWidth', 2.0);
    
    % one method could be to check the gradient of the below lines, and if
    % the gradient surpasses a certain point, you could figure out that
    % there has been a hesitation
%     plot(x(TF1), control(TF1), 'LineWidth', 1.5', 'color', 'k');
%     plot(x(TF3), control(TF3), 'LineWidth', 1.5', 'color', 'b');
%     plot(x(TF2), parkinsons(TF2), 'LineWidth', 1.5', 'color', 'r');
%     plot(x(TF4), parkinsons(TF4), 'LineWidth', 1.5', 'color', 'g');
   
    
    
    
    z = polyfit(x(TF2), parkinsons(TF2), 8);
    y1 = polyval(z, x(TF2));
    %plots terrible curve of best fit, for the local minimas
    %plot(x(TF2),y1, 'LineWidth', 2, 'color', 'k');
    
    
    title("$\textbf{\emph Displacement of Finger and Thumb as a function of time (" + iterations + " frames at 70fps)}$", 'Interpreter','latex', 'FontSize', 20, 'fontweight', 'bold');
    ylabel('$\textbf{\emph Z-Axis displacement from starting position}$', 'fontweight', 'bold', 'fontsize', 16, 'Interpreter','latex');
    xlabel('$\textbf{\emph Frame Number}$', 'fontweight' ,'bold', 'fontsize', 16, 'Interpreter','latex');
    ylim([0 7]);
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
     
    parkinsons_distance = parkinsons(TF3)-parkinsons(TF1);

    
    % getting the average value, ignoring sign
    AverageControlSpeed = abs(mean(ControlSpeed));
    AverageParkinsonsSpeed = abs(mean(ParkinsonsSpeed));
    txt1 = ['$\textbf{\emph Average Control Type Speed: ' num2str(AverageControlSpeed) ' x/frame}$'];
    txt2 = ['$\textbf{\emph Average Parkinsonian Type Speed: ' num2str(AverageParkinsonsSpeed) '}$'];
    txt3 = ['$\textbf{\emph Control Distance Travelled: ' num2str(accumulatedDistanceControl) '}$'];
    txt4 = ['$\textbf{\emph Parkinsonian Distance Travelled: ' num2str(accumulatedDistanceParkinsons) '}$'];
    %defining text at top left of figure
    ylimits = ylim;
    ymax = ylimits(2);
    vert_spacing = ymax/47;  %arbitrary positioning
    
    text(10, ymax-vert_spacing*1, txt1, 'Interpreter','latex');
    text(10, ymax-vert_spacing*2, txt2, 'Interpreter','latex');
    text(10, ymax-vert_spacing*4, txt3, 'Interpreter','latex');
    text(10, ymax-vert_spacing*5, txt4, 'Interpreter','latex');
    
end


function identify_hesitations()

    

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



