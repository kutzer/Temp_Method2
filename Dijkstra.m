function D = Dijkstra(Adj)
% %% Adj & WAdj
%  Adj = zeros(5,5);
%  Adj(1,2) = 1;
%  Adj(1,4) = 1;
%  Adj(2,3) = 1;
%  Adj(2,5) = 1;
%  Adj(3,5) = 1;
%  Adj(4,5) = 1;
%  Adj = Adj + Adj.';
%  Adj;
% 
%  Adj = inf(5,5);
%  for i = 1:5
%      Adj(i,i) = 0;
%  end
%  
%  Adj(1,2) = inf; Adj(2,1) = inf;
%  Adj(1,4) = inf; Adj(4,1) = inf;
%  Adj(2,3) = inf; Adj(3,2) = inf;
%  Adj(2,5) = inf; Adj(5,2) = inf;
%  Adj(3,5) = inf; Adj(5,3) = inf;
%  Adj(4,5) = inf; Adj(5,4) = inf;
%  Adj

%%
nNodes = size(Adj,1);
n_init = 1;
n_goal = nNodes;

for i = 1:nNodes
    dist(i) = inf;
    prev{i} = [];
end

dist(n_init) = 0;
U = 1:nNodes;

n_g = n_init;
%%
while any(U == n_g)
    distTMP = inf;
    for u = U
        if Adj(n_g,u) < distTMP
            C = u;
            distTMP = Adj(n_g,u);
        end
    end
    bin = (U ==C);
    U(bin) = [];
    
    neighbors = find(Adj(:,C) >= 1);
    for neighbor = neighbors.'
        %fprintf('\tneighbor = %d',neighbor);
        alt = dist(C) + Adj(C, neighbor);
        if alt < dist(neighbor)
            dist(neighbor) = alt;
            prev{neighbor}(end+1) = C;
            %fprintf(' - prev{%d}(%d) = %d\n',neighbor,numel(prev{neighbor}),C);
        else
            %fprintf(' - No prev\n');
        end
    end
    
    if isempty(U)
        break
    end
    
    n_g = U(1);
end
%% print result

% for i = 1:numel(dist)
%     fprintf('dist = %d',dist(i));
%     for j = 1:numel(prev{i})
%         fprintf('%d',prev{i}(j));
%     end
%     fprintf(']\n');
% end

%% reconstruct path
path(1) = n_goal;
if isempty(cell2mat(prev)) == 1
    path = [];
else
while path(end) ~= n_init   
    n_now = path(end);
    path(end+1) = prev{n_now}(end);

end
end
path = fliplr(path);

final_dist = dist(n_goal)
D = path;