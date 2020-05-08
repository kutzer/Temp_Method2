%% Problem 2

function b = H(theta,X)
   
    b = [cos(theta), -sin(theta), X(1); sin(theta), cos(theta), X(2); 0,0,1];
    
end