function [ptch_B,txt_B,B] = plotObstacle(varargin)
% Plot obstacle B. Use the function name \plotObstacle" with the inputs B 
% as defined above, and a positive integer i indicating the obstacle 
% number. Your plot should include the following: 
% (1) a patch object of your obstacle (set your obstacle's default color to
% blue for convenience) and 
% (2) the following text centered in the middle of your obstacle: 
% `B_i' (note that i should be the actual number associated with i). 
% Throw an error if an insufficient number of vertices is specified for B  
% or if i is not a positive integer. Return the handle of the patch object  
% of B.

%% Parse input(s)
if nargin == 1
    % Set default value if i is not provided
    % -> This is not officially part of the homework problem, but it is 
    % nice to have.
    B = varargin{1};
    i = 1;
elseif nargin == 2
    % The two-input format is required for the homework problem
    B = varargin{1};
    i = varargin{2};
else
    error('Incorrect number of inputs.');
end

%% Check inputs
% Check number of vertices
if size(B,1) ~= 2
    error('This function requires two-dimensional vertices.');
end
% Check dimension of vertices
if size(B,2) < 3
    error('At least three vertices must be specified.');
end
% Check body index
if i < 1
    error('The specified index must be a positive integer.');
end

%% Confirm that vertices form a convex polygon (optional)
idx = convhull(B(1,:),B(2,:));
if numel(idx)-1 ~= size(B,2)
    warning('Indices of the obstacle as defined do not form a convex polygon.');
end
B = B(:,idx( 1:(end-1) ));

%% Plot the obstacle
% Get the current axes and add the patch object to it.
% -> Common student error: Students will typically create a new figure and
% axes rather than adding to an existing one. This defeats the purpose of
% this function.
axs = gca;
hold(axs,'on');
daspect(axs,[1 1 1]);

% Define patch object properties
b.Vertices = B';            % unique vertices of B
b.Faces = [1:size(B,2),1];  % closed, ordered indices of vertices for B

% Create the patch object
ptch_B = patch(b,'FaceColor','b','FaceAlpha',0.5,'EdgeColor','k','Parent',axs);

% Put text in the center of the polygon
% NOTE: It is acceptable for students to use "xCnt = mean(B(1,:);
% yCnt = mean(B(B(2,:));"
pIn = polyshape(B(1,:),B(2,:));
[xCnt,yCnt] = centroid(pIn);
% Create text
txt_B = text(axs,xCnt,yCnt,sprintf('B_{%d}',i));