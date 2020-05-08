function p = plotCObstacle(CB,i)
cb = transpose(CB);
if size(cb,1) < 3
    error('insufficient number vertices specified for CB');
end

if i < 1
    error('i is not a positive integer');
end

axs = gca;

daspect(axs,[ 1 1 1]);

%% Create patch object

vert = cb;
faces = 1:size(cb,1);

p = patch('Faces',faces,'Vertices',vert,'Facecolor','g','EdgeColor','g','FaceAlpha',0.5);

x_mid = mean(cb(:,1));
y_mid = mean(cb(:,2));


text(x_mid,y_mid,sprintf('CB_%d',i));

end