function [tf,pntALL,vvIntALL] = VCell_segObsInt(pnts01,CB)

[tf,pntALL,vvIntALL] = segmentObstacleIntersect(pnts01,CB);

return

tf = false;
pntALL = [];
n = size(CB,2);
for i = 1:n
    j = i +1;
    if j > n
        j = 1;
    end
    pnts02 = [CB(:,i),CB(:,j)];
    
    [eeInt,evInt,vvInt,pnt] = segmentIntersect(pnts01,pnts02);
    
    if any([eeInt,evInt,vvInt])
        tf = true;
        if nargout == 1
            varargout{1} = tf;
            return
        else
            pntALL =[pntALL, pnt];
%             if size(pnt,1) ~= 2 || size(pnt,2) ~= 1
%                 fprintf('',size(pnt,1),size(pnt,2));
%             end
        end
    end
end

varargout{1} = tf;
varargout{2} = pntALL;