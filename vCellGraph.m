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

%% reduce/eliminate broken lines if they intersect their own obstacle

for lineIDX = 1:size(XY_sort,2)   % for each vertical line
    lineObstacle = CB_idx_sort(lineIDX);    % get the obstacle index whose vertex defines line segment
    
    for breakIDX = 1:2
        % Check to see if broken line segment intersects its defining obstacle
        [tf,pnts,vvIntALL] = VCell_segObsInt(brokenseg{lineIDX}{breakIDX},CB{lineObstacle});
        % Remove vertex-vertex intersections
        pnts(:,vvIntALL) = [];
        if tf && size(pnts,2) > 0 % Intersections will always occur with the vertex that defines the vertical line
            brokenseg{lineIDX}{breakIDX} = [];
            set(pBSeg(lineIDX,breakIDX),'XData',[],'YData',[]);
            drawnow
        end
    end
end

%% cut segments
pltINT = [];
for lineIDX = 1:size(XY_sort,2)   % for each vertical line
    lineObstacle = CB_idx_sort(lineIDX);    % get the obstacle index whose vertex defines line segment
    
    %tf = false;
    for obstacleIDX = 1:numel(CB)
        % Skip
        if obstacleIDX == lineObstacle
            continue
        end
        for breakIDX = 1:2
            %if bin(breakIDX)       % no idea what this is doing
            %    continue
            %end
            
            
            
            [tfNOW,pntALL] = VCell_segObsInt(brokenseg{lineIDX}{breakIDX},CB{obstacleIDX});
            if tfNOW
                
                brokenseg{lineIDX}{breakIDX}
                pntALL(:,1) = [];
                pntALL(:,2) = [];
                pntALL
                mm = size(pntALL,2);
                switch breakIDX
                    case 1
                        dist = sqrt(sum( (pntALL - repmat(brokenseg{lineIDX}{breakIDX}(:,1),1,mm)).^2, 1));
                        ii = find(dist == min(dist),1,'first');
                        brokenseg{lineIDX}{breakIDX}(:,2) = pntALL(:,ii);
                        pltINT(end+1) = plot(axs,pntALL(1,:),pntALL(2,:),'ms');
                        pltINT(end+1) = plot(axs,pntALL(1,ii),pntALL(2,ii),'mx');
                        %                         dist = pntALL(2,:) - brokenseg{i}{k}(2,:);
                        %                         ii = find(dist == min(dist),1,'first');
                        %                         brokenseg{i}{k}(:,1) = pntALL(2,ii);
                    case 2
                        dist = sqrt(sum( (pntALL - repmat(brokenseg{lineIDX}{breakIDX}(:,1),1,mm)).^2, 1));
                        ii = find(dist == min(dist),1,'first');
                        brokenseg{lineIDX}{breakIDX}(:,2) = pntALL(:,ii);
                        pltINT(end+1) = plot(axs,pntALL(1,:),pntALL(2,:),'cs');
                        pltINT(end+1) = plot(axs,pntALL(1,ii),pntALL(2,ii),'cx');
                        %                         dist = pntALL(2,:) - brokenseg{i}{k}(2,:);
                        %                         ii = find(dist == min(dist),1,'first');
                        %                         brokenseg{i}{k}(:,1) = pntALL(2,ii);
                end
            end
        end
    end
end
    
    return
    %{
if ~bin(1)
    plt(lineIDX,1) = plot(axs,brokenseg{lineIDX}{1}(1,:),brokenseg{lineIDX}{1}(2,:),'g','LineWidth',2);
end
if ~bin(2)
    plt(lineIDX,2) = plot(axs,brokenseg{lineIDX}{2}(1,:),brokenseg{lineIDX}{2}(2,:),'r','LineWidth',2);
end
drawnow;

seg{lineIDX} = cell2mat(brokenseg{lineIDX});

end



return

plt
C = cell2mat(seg)
count = 0;
for h = 1:size(C,2)
    x_mid(h) = ((C(1,h+count) + C(1,h+count+1))/2);
    y_mid(h) = ((C(2,h+count) + C(2,h+count+1))/2);
    if h+count+1 < size(C,2)
        count = count + 1;
    else
        break
    end
end
x_mid;
y_mid;
nodes_mid = [x_mid;y_mid];
nodes = [q_init,nodes_mid,q_goal];
% for i = 1:size(nodes,2)
%     if q_init(1) > nodes(1,i)
%         nodes = [nodes(:,1:i) q_init nodes(:,i+1:end)];
%     end
% end
%
% for i = 1:size(nodes,2)
%     if q_goal(1) > nodes(1,i)
%         nodes = [nodes(:,1:i) q_goal nodes(:,i+1:end)];
%     end
% end
%% Object Flags
obsFlag = 0;
nodes
for lineIDX = 1:numel(CB)
    obsFlag = [obsFlag, repmat(lineIDX,1,size(CB{lineIDX},2))];
end

obsFlag = [obsFlag, 0];
%% initialize adjacency matrix
m = size(XY,2);
Adj = zeros(m,m);
wAdj = inf(m,m);
wAdj(logical(eye(m))) = 0;

for lineIDX = 1:size(nodes,2)
    plot_txt(lineIDX) = text(nodes(1,lineIDX),nodes(2,lineIDX),sprintf('%d',lineIDX));
end

%% populate connections in the adjacency

for lineIDX = 1:m
    
    for j = 1:m
        if lineIDX <= j
            continue
        end
        
        if obsFlag(lineIDX) == obsFlag(j) && obsFlag(lineIDX) ~=0
            if abs(lineIDX-j) > 1 || abs(lineIDX-j) == (size(CB{obsFlag(lineIDX)},2)-1)
                continue
            end
        else
            segment01 = [nodes(:,lineIDX),nodes(:,j)];
            isintersect = 0;
            for breakIDX = 1:numel(CB)
                for w = 1:size(CB{breakIDX},2)
                    if w < size(CB{breakIDX},2)
                        segment02 = [CB{breakIDX}(:,w),CB{breakIDX}(:,w+1)];
                    else
                        segment02 = [CB{breakIDX}(:,w),CB{breakIDX}(:,1)];
                    end
                    
                    if logical(segmentIntersect(segment01,segment02)) == 1
                        isintersect = 1;
                        continue
                    end
                end
                if isintersect == 1
                    continue
                end
            end
        end
        if isintersect == 1
            continue
        else
            Adj(lineIDX,j) = 1;
            Adj(j,lineIDX) = 1;
            wAdj(lineIDX,j) = norm(nodes(:,lineIDX)-nodes(:,j));
            wAdj(j,lineIDX) = wAdj(lineIDX,j);
        end
        %edg(i,j) = plot(axs,[nodes(1,i),nodes(1,j)],[nodes(2,i),nodes(2,j)],'b','LineWidth',1.5);
    end
end

VCG = {wAdj,nodes};