function PMI = Method1(Robot_verts, Obstacle_verts, q_init, q_goal)
%% initialize

fig = figure;
axs = axes('Parent',fig);
hold(axs,'on');
daspect(axs,[1 1 1]);

Robot_verts = rand(2,3);
for i = 1:5
    v = 2*(10*rand)*(rand(2,15)-0.5) + 80*(rand(2,1)-1.5);
    cv = convhull(v(1,:),v(2,:));
    Obstacle_verts{i} = v(:,cv(1:end-1));
    ptc(i) = plotCObstacle(Obstacle_verts{i},i);
end

xx = xlim(axs);
yy = ylim(axs);
XY = [xx;yy];
q_init = [diff(XY,1,2).*(2*rand(2,1)-1) + mean(XY,2);30]; %for quick random input and debugging
q_goal = [diff(XY,1,2).*(2*rand(2,1)-1) + mean(XY,2);45];

r_verts = Robot_verts;
obs_verts = Obstacle_verts;
q_i = q_init(1:2);
q_g = q_goal(1:2);
theta = q_init(3);
r = plotRobot(q_init,r_verts);

for i = 1:numel(obs_verts)
    CB{i} = cObstacle(theta,r_verts,obs_verts{i});
end
plt = plot(axs,q_goal(1),q_goal(2),'xr','MarkerSize',10,'LineWidth',2);

XX = xlim(axs);
YY = ylim(axs);
XY = [XX;YY];
%% The method of Robot Motion Planning
Method = vCellGraph(q_i,q_g,CB,XY);
Adjacency = cell2mat(Method(1));
vertices = cell2mat(Method(2));
node_path = Dijkstra(Adjacency)
if isempty(node_path) == 1
    fprintf('no path detected');
else
    q_path_pos = vertices(:,node_path);
    
    for i = 1:size(q_path_pos,2)
        if i >= size(q_path_pos,2)
            break
        else
            plot(axs,[q_path_pos(1,i),q_path_pos(1,i+1)],[q_path_pos(2,i),q_path_pos(2,i+1)],'b','LineWidth',1.5);
        end
    end
    orient = [];
    idx = 1;
    
    for i = 2:size(q_path_pos,2)
        if i >= size(q_path_pos,2)
            break
        else
            orient(idx) = (180-acosd(dot(q_path_pos(i-1:i),q_path_pos(i:i+1))/(norm((q_path_pos(i-1:i)))*norm((q_path_pos(i:i+1))))));
            idx = idx + 1;
        end
    end
    if isempty(orient) == 1
        q_path = [q_path_pos;q_init(3),q_goal(3)];
    else
        q_path = [q_path_pos;q_init(3),orient,q_goal(3)];
    end
    
    row = {'Node','X','Y','Theta'};
    RM = {'Robot_Motion'};
    
    PMI = table([node_path;q_path],'RowNames',row','VariableNames',RM);
end