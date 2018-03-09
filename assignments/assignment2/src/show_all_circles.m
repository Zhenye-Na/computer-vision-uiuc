function show_all_circles(I, cx, cy, rad, threshold, scale, k)
%% I: image on top of which you want to display the circles
%% cx, cy: column vectors with x and y coordinates of circle centers
%% rad: column vector with radii of circles. 
%% The sizes of cx, cy, and rad must all be the same
%% color: optional parameter specifying the color of the circles
%%        to be displayed (red by default)
%% ln_wid: line width of circles (optional, 1.5 by default
color = 'r';
ln_wid = 1;
if nargin < 5
    color = 'r';
end

if nargin < 6
   ln_wid = 1.5;
end

imshow(I); hold on;

theta = 0:0.1:(2*pi+0.1);
cx1 = cx(:,ones(size(theta)));
cy1 = cy(:,ones(size(theta)));
rad1 = rad(:,ones(size(theta)));
theta = theta(ones(size(cx1,1),1),:);
X = cx1+cos(theta).*rad1;
Y = cy1+sin(theta).*rad1;
line(X', Y', 'Color', color, 'LineWidth', ln_wid);

title(sprintf('circles: %d, threshold: %.3f, scale: %.3f, factor k: %.3f', size(cx,1), threshold, scale, k));
