%% HW 4 problem 1a
function [ptch,hg] = plotRobot(q,A)
a = transpose(A);
if size(q,1) ~= 3
    error('incorrect set for q');
end

if size(a,1)<3
    error('incorrect quantity of vertices');
end
axs = gca;

daspect(axs,[ 1 1 1]);

%% Create patch object

vert = a;
faces = 1:size(a,1);

hg = triad('Parent',axs);
ptch = patch('Faces',faces,'Vertices',vert,'Facecolor','r','EdgeColor','r','FaceAlpha',0.5,'Parent',hg);

H_2D = H(q(3),q(1:2));

H_3D(4,4) = 1;
H_3D(1:2,1:2) = H_2D(1:2,1:2);
H_3D(3,3) = 1;
H_3D(1:2,4) = H_2D(1:2,3);

set(hg,'Matrix',H_3D);
end