%importing the data into arrays
controlType = readtable('controlType.csv');
parkinsonsType = readtable('parkinsonsType.csv');

%storing thumb and finger data separately
parkinsonsThumb = parkinsonsType(1:2:end,:);
parkinsonsIndex = parkinsonsType(2:2:end,:);

controlThumb = controlType(1:2:end,:);
controlIndex = controlType(2:2:end,:);

xCT = controlThumb{1:end, 2};
yCT = controlThumb{1:end, 3};
zCT = controlThumb{1:end, 4};

xCI = controlIndex{1:200, 2};
yCI = controlIndex{1:200, 3};
zCI = controlIndex{1:200, 4};

xPT = parkinsonsThumb{1:200, 2};
yPT = parkinsonsThumb{1:200, 3};
zPT = parkinsonsThumb{1:200, 4};

xPI = parkinsonsIndex{1:200, 2};
yPI = parkinsonsIndex{1:200, 3};
zPI = parkinsonsIndex{1:200, 4};

controlThumbPositions = [xCT yCT zCT];
controlIndexPositions = [xCI yCI zCI];

parkinsonsThumbPositions = [xPT yPT zPT];
parkinsonsIndexPositions = [xPI yPI zPI];

%euclydian distance between two co-ordinates in matlab
iterations = 200;
euclydianDistance = zeros(iterations,1);


%fixing figure window size
set(gcf, 'Position',  [25, 25, 1200, 1900]);
xlim([0 200]);
ylim([1 1.5]);

grid on;
trend = animatedline('Color', 'b', 'LineWidth', 2.0);

for k = 1 : iterations
    euclydianDistance(k, 1) = norm(controlThumbPositions(k,1) - controlIndexPositions(k,1));
    addpoints(trend, k, (euclydianDistance(k)));
    drawnow
end