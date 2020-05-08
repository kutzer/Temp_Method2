function appl_a = APPL_A(q,A,B)


n_A = size(A,2);
n_B = size(B,2);
theta = q(3);
A_rot = R(theta)*A;
for i = 1:n_A
    idxA = i;
    idxA_plus_1 = i+1;
    if idxA_plus_1 > n_A
        idxA_plus_1 = 1;
    end
edge = [A_rot(:,idxA),A_rot(:,idxA_plus_1)]; 
v_iA = outwardNorm(edge);
    for j = 1:n_B
        % j-1
        idxB_minus_1 = j - 1;
        if idxB_minus_1 < 1
           idxB_minus_1 = n_B; 
        end
        %j
        idxB = j;
        idxB_plus_1 = j + 1;
        %j+1
        if idxB_plus_1 > n_B
            idxB_plus_1 = 1;
        end
        appl_a = dot(v_iA,(B(:,idxB_minus_1) - B(:,idxB))) >= 0 && dot(v_iA,(B(:,idxB_plus_1) - B(:,idxB))) >= 0;
        if appl_a == 1
            out(i,j) = 1;
        else
            out(i,j) = 0;
        end
    end
end
appl_a = out;
end