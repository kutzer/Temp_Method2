function [tf,pntALL,vvIntALL] = segmentObstacleIntersect(pnts01,CB)
% SEGMENTOBSTACLEINTERSECT checks to see if a segment defined using a set
% of two end-points intersects the edges of a polygon.
%   tf = SEGMENTOBSTACLEINTERSECT(pnts01,CB) 
%       pnts01 - [x1, x2; y1, y2];
%       CB     - 2xN array of *unique* vertices
%       tf     - true if the segment intersects the obstacle
%
%   M. Kutzer, 16Apr2020, JHU-EP

global debugLINE debugINT debugVERT

debugON = true;

if debugON
    if isempty(debugLINE) || ~ishandle(debugLINE)
        debugLINE = plot(gca,nan,nan,'m','LineWidth',3);
    end
    if isempty(debugINT) || ~ishandle(debugINT)
        debugINT = plot(gca,nan,nan,'sm','LineWidth',2);
    end
    if isempty(debugVERT) || ~ishandle(debugVERT)
        debugVERT = plot(gca,nan,nan,'dm','LineWidth',2);
    end
    
    set(debugLINE,'Visible','on');
    set(debugINT,'Visible','on','XData',[],'YData',[]);
    set(debugVERT,'Visible','on','XData',[],'YData',[]);
end

% Set the default value of the binary output
tf = false; % No intersect
pntALL = [];

%% Check if both segment end-points are inside of the polygon
[pnt_in_obstacle,pnt_on_obstacle] = inpolygon(pnts01(1,:),pnts01(2,:),CB(1,:),CB(2,:));
if all( pnt_in_obstacle & ~pnt_on_obstacle )
    tf = true;
    return
end

%% Check for intersections
pntALL = [];
vvIntALL = logical([]);
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
        pntALL = [pntALL,pnt];
        vvIntALL = [vvIntALL,logical(vvInt)];
        if debugON
            set(debugINT,'XData',pntALL(1,:),'YData',pntALL(2,:));
            set(debugVERT,'XData',pntALL(1,vvIntALL),'YData',pntALL(2,vvIntALL));
            drawnow
        end
    end
end
if debugON
    set(debugLINE,'Visible','off');
    set(debugINT,'Visible','off');
end

end

function appendData(h,x,y)
xx = get(h,'XData');
yy = get(h,'YData');
xx = [xx,x];
yy = [yy,y];
set(h,'XData',xx,'YData',yy);
end