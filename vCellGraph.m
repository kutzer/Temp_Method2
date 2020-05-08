function VCG = vCellGraph(q_init,q_goal,CB,bounds)

fig = figure;
axs = axes('Parent',fig);
hold(axs,'on');
daspect(axs,[1 1 1]);
% q_init = [rand; rand]; for quick random input and debugging
% q_goal = [rand; rand];
for i = 1:5
%     v = 2*(10*rand)*(rand(2,15)-0.5) + 80*(rand(2,1)-1.5);
%     k = convhull(v(1,:),v(2,:));
%     CB{i} = v(:,k);
    
    ptc(i) = plotCObstacle(CB{i},i);
end
plt = plot(axs,q_init(1),q_init(2),'sg','MarkerSize',10,'LineWidth',2);
plt(2) = plot(axs,q_goal(1),q_goal(2),'xr','MarkerSize',10,'LineWidth',2);

XX = bounds(1,:);
YY = bounds(2,:);
%% combine vertices
XY = [];
CB_idx = [];

for i = 1:numel(CB)
    XY = [XY, CB{i}];
    CB_idx = [CB_idx, repmat(i,1,size(CB{i},2))];
end
[~,idx] = sort(XY(1,:));
XY_sort = XY(:,idx);
CB_idx_sort = CB_idx(:,idx);

%% create verticle lines
pltINT = [];
for i = 1:size(XY_sort,2)
    brokenseg{i}{1} = [XY_sort(1,i), XY_sort(1,i); YY(2), XY_sort(2,i)];
    brokenseg{i}{2} = [XY_sort(1,i), XY_sort(1,i); XY_sort(2,i), YY(1)];
    
    obsnum = CB_idx_sort(i);
    n = size(CB{obsnum},2);
    bin = false(1,2);
    %{
    for j = 1:n
        j0=j;
        j1 = j+1;
        if j1 > n
            j1 = 1;
        end
        edge_j = [CB{obsnum}(:,j0),CB{obsnum}(:,j1)];
        
        for k = 1:2
            [eeint,~,~,pnt] = segmentIntersect(brokenseg{i}{k}, edge_j);
            if eeint
                bin(k) = bin(k) || true;
                continue
            end
        end
    end
    %}
    %         if all(bin)
    %             continue;
    %         end
    
    for k = 1:2
        if bin(k)
            continue
        end
        tf = false;
        for obsIDX = 1:numel(CB)
            if obsIDX == obsnum
                continue
            end
            
            [tfNOW,pntALL] = VCell_segObsInt(brokenseg{i}{k},CB{obsIDX});
            if tfNOW
                
                brokenseg{i}{k}
                pntALL(:,1) = [];
                pntALL(:,2) = [];
                pntALL
                mm = size(pntALL,2);
                switch k
                    case 1
                        dist = sqrt(sum( (pntALL - repmat(brokenseg{i}{k}(:,1),1,mm)).^2, 1));
                        ii = find(dist == min(dist),1,'first');
                        brokenseg{i}{k}(:,2) = pntALL(:,ii);
                        pltINT(end+1) = plot(axs,pntALL(1,:),pntALL(2,:),'ms');
                        pltINT(end+1) = plot(axs,pntALL(1,ii),pntALL(2,ii),'mx');
%                         dist = pntALL(2,:) - brokenseg{i}{k}(2,:);
%                         ii = find(dist == min(dist),1,'first');
%                         brokenseg{i}{k}(:,1) = pntALL(2,ii);
                    case 2                        
                        dist = sqrt(sum( (pntALL - repmat(brokenseg{i}{k}(:,1),1,mm)).^2, 1));
                        ii = find(dist == min(dist),1,'first');
                        brokenseg{i}{k}(:,2) = pntALL(:,ii);
                        pltINT(end+1) = plot(axs,pntALL(1,:),pntALL(2,:),'cs');
                        pltINT(end+1) = plot(axs,pntALL(1,ii),pntALL(2,ii),'cx');
%                         dist = pntALL(2,:) - brokenseg{i}{k}(2,:);
%                         ii = find(dist == min(dist),1,'first');
%                         brokenseg{i}{k}(:,1) = pntALL(2,ii);
                end
            end
        end
    end
    
    if ~bin(1)
        plt(i,1) = plot(axs,brokenseg{i}{1}(1,:),brokenseg{i}{1}(2,:),'g','LineWidth',2);
    end
    if ~bin(2)
        plt(i,2) = plot(axs,brokenseg{i}{2}(1,:),brokenseg{i}{2}(2,:),'r','LineWidth',2);
    end
    drawnow;
    
    seg{i} = cell2mat(brokenseg{i});
    
end
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
for i = 1:numel(CB)
    obsFlag = [obsFlag, repmat(i,1,size(CB{i},2))];
end

obsFlag = [obsFlag, 0];
%% initialize adjacency matrix
m = size(XY,2);
Adj = zeros(m,m);
wAdj = inf(m,m);
wAdj(logical(eye(m))) = 0;

for i = 1:size(nodes,2)
    plot_txt(i) = text(nodes(1,i),nodes(2,i),sprintf('%d',i));
end

%% populate connections in the adjacency

for i = 1:m
    
    for j = 1:m
        if i <= j
            continue
        end
    
        if obsFlag(i) == obsFlag(j) && obsFlag(i) ~=0
            if abs(i-j) > 1 || abs(i-j) == (size(CB{obsFlag(i)},2)-1)
                continue
            end
        else
                segment01 = [nodes(:,i),nodes(:,j)];
                isintersect = 0;
                for k = 1:numel(CB)
                    for w = 1:size(CB{k},2)
                        if w < size(CB{k},2)
                        segment02 = [CB{k}(:,w),CB{k}(:,w+1)];
                        else
                        segment02 = [CB{k}(:,w),CB{k}(:,1)];
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
             Adj(i,j) = 1;
             Adj(j,i) = 1;
             wAdj(i,j) = norm(nodes(:,i)-nodes(:,j));
             wAdj(j,i) = wAdj(i,j);
         end
            %edg(i,j) = plot(axs,[nodes(1,i),nodes(1,j)],[nodes(2,i),nodes(2,j)],'b','LineWidth',1.5);
    end
end

VCG = {wAdj,nodes};