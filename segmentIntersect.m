function [eeInt,evInt,vvInt,pnt,isParallel] = segmentIntersect(pnts01, pnts02)
%SEGMENTINTERSECT determines whether an intersection occurs between two
%segments.
%   [eeInt,evInt,vvInt,pnt] = segmentIntersect(pnts01, pnts02) calculates a
%   line segment from pnts01 and pnts02, and calculates intersect
%   conditions.
%
%   Function Inputs
%       pnts01 = [x01_1, x01_2; y01_1, y01_2]
%       pnts02 = [x02_1, x02_2; y02_1, y02_2]
%
%   Function Outputs
%       eeInt - binary that is true if there is an edge/edge intersect
%       evInt - binary that is true if there is an edge/vertex intersect
%       vvInt - binary that is true if there is an vertex/vertex intersect
%       pnt = [x; y] - the point of intersection (for debugging and stuff)
%
%   M.Kutzer, 02Apr2020, JHU-EP

ZERO = 1e-6;

eeInt = logical([]);
evInt = logical([]);
vvInt = logical([]);
pnt = [];

%% Fit our coefficients
M01 = pnts01*[0, 1; 1, 1]^(-1);
M02 = pnts02*[0, 1; 1, 1]^(-1);

%% Define "slope" matrix
MM = [M01(:,1), -M02(:,1)];

%% Define "offset" matrix
BB = (M02(:,2) - M01(:,2));

%% Check for parallel line condition
isParallel = false;
if abs( det(MM) ) < ZERO
    % Lines are parallel!
    isParallel = true;
    
    % Check for overlapping lines
    for s = [0,1]
        xy01 = M01*[s; 1];  % Calculate end-point
        xy02 = M02*[s; 1];  % Calculate end-point
        
        if abs( det(M01) ) < ZERO
            M01
            error('Line is defined by a singular matrix')
        end
        if abs( det(M02) ) < ZERO
            M02
            error('Line is defined by a singular matrix')
        end
        S1 = M01^(-1) * xy02;   % Find where segment 2's endpoint lies on segment 1
        S2 = M02^(-1) * xy01;   % Find where segment 1's endpoint lies on segment 2
        
        if S1(1) > 0 && S1(1) < 1
            % Intersect (segment 2's endpoint lies on segment 1)
            eeInt(end+1) = true;
            evInt(end+1) = true;
            vvInt(end+1) = false;
            pnt(:,end+1) = xy02;
        end
        if S2(1) > 0 && S2(1) < 1
            % Intersect (segment 1's endpoint lies on segment 2)
            eeInt(end+1) = true;
            evInt(end+1) = true;
            vvInt(end+1) = false;
            pnt(:,end+1) = xy01;
        end
        % check for vertex/vertex (double check me)
        if (S1(1) == 1 || S1(1) == 0) && (S2(1) == 1 || S2(1) == 0)
            eeInt(end+1) = false;
            evInt(end+1) = false;
            vvInt(end+1) = true;
            if (S1(1) == 1 || S1(1) == 0)
                pnt(:,end+1) = xy02;
            else
                pnt(:,end+1) = xy01;
            end
        end
    end
    
    if isempty(pnt)
        % No intersection was found
        eeInt(end+1) = false;
        evInt(end+1) = false;
        vvInt(end+1) = false;
    end
    
    return
end
        
%% Calculate s-values
s1s2 = MM^(-1) * BB;
s1 = s1s2(1);
s2 = s1s2(2);

%% Check our conditions
%if (s1 == 0 || s1 == 1) && (s2 == 0 || s2 == 1)
if (abs(s1-0) < ZERO || abs(s1-1) < ZERO) && (abs(s2-0) < ZERO || abs(s2-1) < ZERO)
    % Vertex/Vertex
    eeInt(end+1) = false;
    evInt(end+1) = false;
    vvInt(end+1) = true;
else
    
    if (s1 > 0 && s1 < 1) && (s2 >0 && s2 < 1)
        % Edge/Edge
        eeInt(end+1) = true;
        evInt(end+1) = false;
        vvInt(end+1) = false;
    end
    
    if (s1 == 0 || s1 == 1) && (s2 >0 && s2 < 1)
        % Vertex/Edge
        eeInt(end+1) = false;
        evInt(end+1) = true;
        vvInt(end+1) = false;
    end
    
    if (s1 > 0 && s1 < 1) && (s2 == 0 || s2 == 1)
        % Edge/Vertex
        eeInt(end+1) = false;
        evInt(end+1) = true;
        vvInt(end+1) = false;
    end
end

%% Check for no intersect
if isempty(eeInt)
    eeInt(end+1) = false;
    evInt(end+1) = false;
    vvInt(end+1) = false;
end

%% Calculate the point of intersect
pnt = M01*[s1; 1];
%pnt = M02*[s2; 1];
