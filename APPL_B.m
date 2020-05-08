function appl_b = APPL_B(q,A,B)


n_A = size(A,2);
n_B = size(B,2);
theta = q(3);
A_rot = R(theta)*A;
for i = 1:n_B
    idxB = i;
    idxB_plus_1 = i+1;
    if idxB_plus_1 > n_B
        idxB_plus_1 = 1;
    end
edge = [B(:,idxB),B(:,idxB_plus_1)]; 
v_iB = outwardNorm(edge);
    for j = 1:n_A
        % j-1
        idxA_minus_1 = j - 1;
        if idxA_minus_1 < 1
           idxA_minus_1 = n_A; 
        end
        %j
        idxA = j;
        idxA_plus_1 = j + 1;
        %j+1
        if idxA_plus_1 > n_A
            idxA_plus_1 = 1;
        end
        appl_b = dot(v_iB,(A_rot(:,idxA_minus_1) - A_rot(:,idxA))) >= 0 && dot(v_iB,(A_rot(:,idxA_plus_1) - A_rot(:,idxA))) >= 0;
        if appl_b == 1
            out(i,j) = 1;
        else
            out(i,j) = 0;
        end
    end
end
appl_b = transpose(out);
end