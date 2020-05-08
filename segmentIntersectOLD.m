function [eeInt,evInt, vvInt, pnt] = segmentIntersect(pnts01, pnts02)


%% fit coefficients
M01 = pnts01*[0,1;1,1]^(-1);
M02 = pnts02*[0,1;1,1]^(-1);

%% calc s values

s1s2 = [M01(:,1), -M02(:,1)]^(-1) * (M02(:,2)-M01(:,2));
s1 = s1s2(1);
s2 = s1s2(2);

%% check conditions
eeInt = false;
evInt = false;
vvInt = false;
pnt = [];
if (s1 > 0 && s1 < 1) && (s2 > 0 && s2 < 1)
    eeInt = true;
end

if (s1 == 0 || s1 == 1) && (s2 == 0 || s2 == 1)
    vvInt = true;
end

if (s1 == 0 || s1 == 1) && (s2 > 0 && s2 < 1)
    evInt = true;
end

if (s1 > 0 && s1 < 1) && (s2 == 0 || s2 == 1)
    evInt = true;
end
%% cal point of of intersection

pnt = M01.*[s1,1];
pnt = M02.*[s2,1];
end