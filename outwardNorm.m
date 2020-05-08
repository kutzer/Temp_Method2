function oNorm = outwardNorm(edge)

v = edge(:,2) - edge(:,1);
v(3,1) = 0;

z = [0;0;1];

oNorm = cross(v,z);
oNorm(3) = [];

end