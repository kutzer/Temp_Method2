%function PMI = Method2(Robot_verts, Obstacle_verts, q_init, q_goal)
% This can be a script instead of a function. 

%% start with a clean slate
clear all
close all
clc

%% initialize
% Create figure & axes
fig = figure('Name','Method2','Tag','fig_Method2');
axs = axes('Parent',fig,'Tag','axs_Method2');
hold(axs,'on');
daspect(axs,[1 1 1]);

% Define random obstacles & plot
n = 5;
for i = 1:n
    v = 2*(10*rand)*(rand(2,15)-0.5) + 80*(rand(2,1)-0.5);
    cv = convhull(v(1,:),v(2,:));
    obs_verts{i} = v(:,cv(1:end-1));    % Obstacle vertices
    [pObs(i),tObs(i)] = plotObstacle(obs_verts{i},i);
    set(pObs(i),'Tag',sprintf('obstacle%d_Method2',i));
    set(tObs(i),'Tag',sprintf('obstacle%d_Method2',i),'Visible','off');
end

% Define bounds of the environment
xx = xlim(axs);
yy = ylim(axs);
XY = [xx;yy];

% Define initial and goal configuration
q_init = [diff(XY,1,2).*(2*rand(2,1)-1) + mean(XY,2);30]; %for quick random input and debugging
q_goal = [diff(XY,1,2).*(2*rand(2,1)-1) + mean(XY,2);45];

% Define & Plot the robot
Robot_verts = 2*5*(rand(2,3)-0.5);
r_verts = Robot_verts;
[pRob,hRob] = plotRobot(q_init,r_verts);
set(pRob,'Tag','robot_Method2');    % Robot patch object
set(hRob,'Tag','robot_Method2');    % Robot hgtransform object

% Creat & plot configuration space obstacles
theta = q_init(3);
for i = 1:numel(obs_verts)
    CB{i} = cObstacle(theta,r_verts,obs_verts{i});
    pCObs(i) = plotCObstacle(CB{i},i);
    set(pCObs(i),'Tag',sprintf('cobstacle%d_Method2',i));
end
pInit = plot(axs,q_init(1),q_init(2),'og','MarkerSize',10,'LineWidth',2,'Tag','qinit_Method2');
pGoal = plot(axs,q_goal(1),q_goal(2),'xr','MarkerSize',10,'LineWidth',2,'Tag','qinit_Method2');

% Update bounds of the environment
xx = xlim(axs);
yy = ylim(axs);
XY = [xx;yy];

%% The method of Robot Motion Planning
% Visibility graph
q_i = q_init(1:2);
q_g = q_goal(1:2);
Method = vCellGraph(q_i,q_g,CB,XY,axs);

return

%% Method of finding path
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