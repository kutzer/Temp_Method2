function CB = cObstacle(theta,A,B)

if size(A,2) < 3
    error('insufficient number vertices specified for A');
end

if size(B,2) < 3
    error('insufficient number vertices specified for B');
end

if numel(theta) == 1
    q(3,1) = theta;
    q(1:2,1) = 0;
end

theta = q(3);
A_rot = R(theta)*A;
appl_A = APPL_A(q,A,B);
appl_B = APPL_B(q,A,B);

CB = [];
n_A = size(appl_A,1);
n_B = size(appl_B,1);
for i = 1:size(appl_A,1)
    for j = 1:size(appl_B,2)
        if appl_A(i,j) == 1
            CB(:,end+1) = B(1:2,j)-A_rot(1:2,i);
        end
           
        if appl_B(i,j) == 1
            CB(:,end+1) = B(1:2,j)-A_rot(1:2,i);
            
        end
    end
end
ind = convhull(CB(1,:),CB(2,:));
ind(end) = [];
CB = CB(:,ind);