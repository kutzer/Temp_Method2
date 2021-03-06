function VCG = vCellGraph(q_init,q_goal,CB,bounds,axs)

VCG = [];

%% Set defaults
% We shouldn't need to create an all-new plot in this function. Ideally, we
% can just use an existing one.
if nargin < 5
    % Create new figure
    fig = figure;
    axs = axes('Parent',fig,'Tag','vCellGraph');
    hold(axs,'on','Tag','vCellGraph');
    daspect(axs,[1 1 1]);
    % Plot obstacles
    for lineIDX = 1:numel(CB)
        ptc(lineIDX) = plotCObstacle(CB{lineIDX},lineIDX);
        set(ptc(lineIDX),'Tag','vCellGraph');
    end
    pInit = plot(axs,q_init(1),q_init(2),'sg','MarkerSize',10,'LineWidth',2,'Tag','vCellGraph');
    pGoal = plot(axs,q_goal(1),q_goal(2),'xr','MarkerSize',10,'LineWidth',2,'Tag','vCellGraph');
else
    % We already have a plot!
    delete(findobj(0,'Tag','vCellGraph'));
end

%% Parse bounds
XX = bounds(1,:);
YY = bounds(2,:);

%% combine vertices & create CB index array
XY = [];
CB_idx = [];
for obstacleIDX = 1:numel(CB)
    XY = [XY, CB{obstacleIDX}];
    CB_idx = [CB_idx, repmat(obstacleIDX,1,size(CB{obstacleIDX},2))];
end

% Sort lines by x-value
[~,idx] = sort(XY(1,:));
XY_sort = XY(:,idx);
CB_idx_sort = CB_idx(:,idx);

%% plot initial vertical lines
set(axs,'XTick',XY_sort(1,:));
for lineIDX = 1:size(XY_sort,2)
    xTickLabel{lineIDX} = sprintf('Line %d',lineIDX);
    segment{lineIDX} = [XY_sort(1,lineIDX), XY_sort(1,lineIDX); YY(2), YY(1)];    % Top-to-bottom
    pSeg(lineIDX) = plot(axs,segment{lineIDX}(1,:),segment{lineIDX}(2,:),':k','Tag','vCellGraph');
end
set(axs,'XTickLabel',xTickLabel,'XTickLabelRotation',90);

%% break vertical lines
for lineIDX = 1:size(XY_sort,2)
    % create broken segments
    brokenseg{lineIDX}{1} = [XY_sort(1,lineIDX), XY_sort(1,lineIDX); YY(2), XY_sort(2,lineIDX)];
    brokenseg{lineIDX}{2} = [XY_sort(1,lineIDX), XY_sort(1,lineIDX); XY_sort(2,lineIDX), YY(1)];
    
    % plot broken segments
    colors = 'rb';
    for breakIDX = 1:2
        pBSeg(lineIDX,breakIDX) = plot(axs,brokenseg{lineIDX}{breakIDX}(1,:),brokenseg{lineIDX}{breakIDX}(2,:),...
            ['--.',colors(breakIDX)],'LineWidth',1.5,'MarkerSize',20,'Tag','vCellGraph');
    end
end

%% eliminate broken line segments if they intersect their own obstacle
for lineIDX = 1:size(XY_sort,2)   % for each vertical line
    lineObstacle = CB_idx_sort(lineIDX);    % get the obstacle index whose vertex defines line segment
    
    for breakIDX = 1:2
        % Check to see if broken line segment intersects its defining obstacle
        [tf,pnts,vvIntALL] = VCell_segObsInt(brokenseg{lineIDX}{breakIDX},CB{lineObstacle});
        % Remove vertex-vertex intersections
        pnts(:,vvIntALL) = [];
        if tf && size(pnts,2) > 0
            brokenseg{lineIDX}{breakIDX} = [];  % An "empty" segment has been removed
            set(pBSeg(lineIDX,breakIDX),'XData',[],'YData',[]);
            drawnow
        end
    end
end

%% cut remaining segments
pltINT = [];
for lineIDX = 1:size(XY_sort,2)   % for each vertical line
    lineObstacle = CB_idx_sort(lineIDX);    % get the obstacle index whose vertex defines line segment
    
    for obstacleIDX = 1:numel(CB)
        % Skip the obstacle that defines the line segment
        if obstacleIDX == lineObstacle
            continue
        end
        fprintf('[Defining Obstacle, Checking Obstacle] = [%d,%d]\n',lineObstacle,obstacleIDX);
        
        % Check lower and upper break
        for breakIDX = 1:2
            % Skip broken line segments that have been removed
            if isempty(brokenseg{lineIDX}{breakIDX})
                continue
            end
            
            % Find any/all intersections
            [tfNOW,pntALL] = VCell_segObsInt(brokenseg{lineIDX}{breakIDX},CB{obstacleIDX});
            if tfNOW
                mm = size(pntALL,2);
                switch breakIDX
                    case 1 % Top
                        % Special case!!!
                        %   Check if "defining" point lies inside of
                        %   intersecting obstacle
                        [pnt_in_obstacle,pnt_on_obstacle] = inpolygon(...
                            brokenseg{lineIDX}{breakIDX}(1,2),brokenseg{lineIDX}{breakIDX}(2,2),...
                            CB{obstacleIDX}(1,:),CB{obstacleIDX}(2,:));
                        if all( pnt_in_obstacle & ~pnt_on_obstacle )
                            % Defining point lies within the polygon that
                            % intersects it!
                            brokenseg{lineIDX}{breakIDX} = [];  % An "empty" segment has been removed
                            set(pBSeg(lineIDX,breakIDX),'XData',[],'YData',[]);
                            drawnow
                        else
                            % Cut the segment normally
                            dist = sqrt(sum( (pntALL - repmat(brokenseg{lineIDX}{breakIDX}(:,2),1,mm)).^2, 1));
                            ii = find(dist == min(dist),1,'first');
                            brokenseg{lineIDX}{breakIDX}(:,1) = pntALL(:,ii);   % Cut segment
                            
                            % Plot intersections
                            pltINT(end+1) = plot(axs,pntALL(1,:),pntALL(2,:),'ms','LineWidth',3,'MarkerSize',12,'Tag','vCellGraph');
                            pltINT(end+1) = plot(axs,pntALL(1,ii),pntALL(2,ii),'mx','LineWidth',3,'MarkerSize',12,'Tag','vCellGraph');
                            % Plot cut segment
                            %fprintf('Intersect found! Cutting at the "x" [ENTER TO CONTINUE]\n');
                            %pause
                            set(pBSeg(lineIDX,breakIDX),'XData',brokenseg{lineIDX}{breakIDX}(1,:),'YData',brokenseg{lineIDX}{breakIDX}(2,:));
                        end
                    case 2 % Bottom
                        % Special case!!!
                        %   Check if "defining" point lies inside of
                        %   intersecting obstacle
                        [pnt_in_obstacle,pnt_on_obstacle] = inpolygon(...
                            brokenseg{lineIDX}{breakIDX}(1,1),brokenseg{lineIDX}{breakIDX}(2,1),...
                            CB{obstacleIDX}(1,:),CB{obstacleIDX}(2,:));
                        if all( pnt_in_obstacle & ~pnt_on_obstacle )
                            % Defining point lies within the polygon that
                            % intersects it!
                            brokenseg{lineIDX}{breakIDX} = [];  % An "empty" segment has been removed
                            set(pBSeg(lineIDX,breakIDX),'XData',[],'YData',[]);
                            drawnow
                        else
                            % Cut the segment normally
                            dist = sqrt(sum( (pntALL - repmat(brokenseg{lineIDX}{breakIDX}(:,1),1,mm)).^2, 1));
                            ii = find(dist == min(dist),1,'first');
                            brokenseg{lineIDX}{breakIDX}(:,2) = pntALL(:,ii);   % Cut segment
                            
                            % Plot intersections
                            pltINT(end+1) = plot(axs,pntALL(1,:),pntALL(2,:),'cs','LineWidth',3,'MarkerSize',12,'Tag','vCellGraph');
                            pltINT(end+1) = plot(axs,pntALL(1,ii),pntALL(2,ii),'cx','LineWidth',3,'MarkerSize',12,'Tag','vCellGraph');
                            % Plot cut segment
                            %fprintf('Intersect found! Cutting at the "x" [ENTER TO CONTINUE]\n');
                            %pause
                            set(pBSeg(lineIDX,breakIDX),'XData',brokenseg{lineIDX}{breakIDX}(1,:),'YData',brokenseg{lineIDX}{breakIDX}(2,:));
                        end
                end
            end
        end
    end
end

%% Find center points of remaining line segments
brokensegMIDPOINTS = [];
pMID = plot(axs,nan,nan,'.k','MarkerSize',25,'Tag','vCellGraph');
for lineIDX = 1:size(XY_sort,2)
    for breakIDX = 1:2
        
        if isempty(brokenseg{lineIDX}{breakIDX})
            % Skip broken line segments that have been removed
            continue
        else
            % Calculate midpoint
            brokensegMIDPOINTS(:,end+1) = sum(brokenseg{lineIDX}{breakIDX},2)./2;
            set(pMID,'XData',brokensegMIDPOINTS(1,:),'YData',brokensegMIDPOINTS(2,:));
            drawnow
        end
        
    end
end

%% declutter debug plot
delete(pltINT);

%% populate connections in the adjacency

% TODO - YOU STILL NEED TO INITIALIZE YOUR ADJACENCY AND WEIGHTED ADJACENCY

vertsXY = [q_init(1:2,1),brokensegMIDPOINTS,q_goal(1:2,1)];
pADJ = [];
for i = 1:size(vertsXY,2)
    for j = 1:size(vertsXY,2)
        
        if i <= j
            continue
        end
        % Define possible connection
        pnts01 = [vertsXY(:,i),vertsXY(:,j)];
        % Check for intersections with obstacles
        for obstacleIDX = 1:numel(CB)
            isIntersect = VCell_segObsInt(pnts01,CB{obstacleIDX});
            if isIntersect
                break
            end
        end
        
        % If no intersection occured, create adjacency
        if ~isIntersect
            Adj(i,j) = 1;
            Adj(j,i) = 1;
            wAdj(i,j) = norm(vertsXY(:,i)-vertsXY(:,j));
            wAdj(j,i) = wAdj(i,j);
            
            pltINT(end+1) = plot(axs,pnts01(1,:),pnts01(2,:),'-m','LineWidth',1.5,'Tag','vCellGraph');
            drawnow
        end
        %edg(i,j) = plot(axs,[nodes(1,i),nodes(1,j)],[nodes(2,i),nodes(2,j)],'b','LineWidth',1.5);
    end
end

VCG = {wAdj,vertsXY};
%}
