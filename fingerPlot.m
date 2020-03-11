%importing the data into arrays
controlType = readtable('./data/control/controlType.csv');
parkinsonsType = readtable('./data/parkinsons/parkinsonsType.csv');

%storing thumb and finger data separately
parkinsonsThumb = parkinsonsType(1:2:end,:);
parkinsonsIndex = parkinsonsType(2:2:end,:);

controlThumb = controlType(1:2:end,:);
controlIndex = controlType(2:2:end,:);

frames = 100;


for i = 1 : frames
    
    %storing individual x y z components in a variable
    xCT = controlThumb{i, 2};
    yCT = controlThumb{i, 3};
    zCT = controlThumb{i, 4};
    
    xCI = controlIndex{i, 2};
    yCI = controlIndex{i, 3};
    zCI = controlIndex{i, 4};
    
    xPT = parkinsonsThumb{i, 2};
    yPT = parkinsonsThumb{i, 3};
    zPT = parkinsonsThumb{i, 4};
    
    xPI = parkinsonsIndex{i, 2};
    yPI = parkinsonsIndex{i, 3};
    zPI = parkinsonsIndex{i, 4};
    
    
    grid on;
    %3d plot of the euclydian co-ordinates
    plot3(xCI,yCI,zCI,'o','LineWidth', 2.0);
    hold on;
    plot3(xCT,yCT,zCT,'o','LineWidth', 2.0);
    
    %inverting z-axis
    set(gca, 'ZDir','reverse');
    
    %fixing figure window size
    set(gcf, 'Position',  [25, 25, 1200, 1900]);
    
    %figure axis boundaries
    
    xlim([13 20]);
    ylim([5 20]);
    zlim([-4 2]);

    
    %figure axis lavels
    xlabel("x-axis");
    ylabel("y-axis");
    zlabel("z-axis");
    
    
    pause(.05);  
    
end





