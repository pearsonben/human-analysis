controlType = readtable('controlType.csv');
parkinsonsType = readtable('parkinsonsType.csv');

frames = 300;

for i = 1 : frames
    
    x1CT = controlType{1*i:2*i,2};
    x2CT = controlType{2*i:2*i,2};
   
    y1CT = controlType{1*i:2*i,3};
    y2CT = controlType{2*i:2*i,3};
    
    z1CT = controlType{1*i:2*i,4};
    z2CT = controlType{2*i:2*i,4};
    
    %plot3(xCT, yCT, zCT, 'o');
    
    plot3(x1CT, y1CT, z1CT, x2CT, y2CT, z2CT, 'o', 'LineWidth', 2.0);
    plot3(x2CT, y2CT, z2CT, 'o', 'LineWidth', 2.0);

    set(gcf, 'Position',  [25, 25, 1200, 1900]);
    xlim([10,20]);
    ylim([5,20]);
    zlim([-4,2]);
    
    
    pause(.05);
end