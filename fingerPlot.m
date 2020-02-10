controlType = readtable('controlType.csv');
parkinsonsType = readtable('parkinsonsType.csv');

xCT = controlType(1:end, 2);
yCT = controlType(1:end, 3);
zCT = controlType(1:end, 4);

xPT = parkinsonsType(1:end, 2);
yPT = parkinsonsType(1:end, 3);
zPT = parkinsonsType(1:end, 4);