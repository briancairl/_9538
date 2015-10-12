clc;
clear;

M1       = meshread('models/cat0.off');
D1       = generate_spatial_descriptors(M1,50,0,500,5,'GEOD');

M2       = meshread('models/centaur0.off');
D2       = generate_spatial_descriptors(M2,50,0,500,5,'GEOD');


figure(1)
cla
patch('Faces',M1.E.','Vertices',M1.V.','FaceColor','b')
axis equal
shg


figure(2)
cla
patch('Faces',M2.E.','Vertices',M2.V.','FaceColor','b')
axis equal
shg




[~,d] = knnsearch(D1.',D2.');

sum(d)