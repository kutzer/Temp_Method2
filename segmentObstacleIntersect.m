function [tf,pntALL] = segmentObstacleIntersect(pnts01,CB)
% SEGMENTOBSTACLEINTERSECT checks to see if a segment defined using a set
% of two end-points intersects the edges of a polygon.
%   tf = SEGMENTOBSTACLEINTERSECT(pnts01,CB) 
%       pnts01 - [x1, x2; y1, y2];
%       CB     - 2xN array of *unique* vertices
%       tf     - true if the segment intersects the obstacle
%
%   M. Kutzer, 16Apr2020, JHU-EP

global debugLINE

debugON = false;

if debugON
    if isempty(debugLINE) || ~ishandle(debugLINE)
        debugLINE = plot(gca,nan,nan,'m','LineWidth',3);
    end
    set(debugLINE,'Visible','on');
end

% Set the default value of the binary output
tf = false; % No intersect

%% Check if the segment end-points are inside of the polygon
pnt_in_obstacle = inpolygon(pnts01(1,:),pnts01(2,:),CB(1,:),CB(2,:));
if any(pnt_in_obstacle)
    tf = true;
    return
end

%% Check for intersections
pntALL = [];
n = size(CB,2);
for i = 1:n
    j = i+1;
    if j > n
        j = 1;
    end
    pnts02 = [CB(:,i),CB(:,j)];
    
    if debugON
        set(debugLINE,'XData',pnts02(1,:),'YData',pnts02(2,:));
        drawnow;
    end
    
    [eeInt,evInt,vvInt,pnt] = segmentIntersect(pnts01, pnts02);
    
    if any([eeInt,evInt,vvInt])
        tf = true;
        if debugON
            set(debugLINE,'Visible','off');
        end
        pntALL = [pntALL,pnt];
    end
end
if debugON
    set(debugLINE,'Visible','off');
end