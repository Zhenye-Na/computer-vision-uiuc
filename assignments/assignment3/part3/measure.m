%% Input image
im = imread('CSL.jpg', 'jpg'); 

vp_1 = [-202 215 1]';
vp_2 = [1371 230 1]';
vp_3 = [503 4867 1]';

%% Compute parameters of Horizontal line 
% regularize a^2 + b^2 = 1.
horizon = real(cross(vp_1', vp_2'));
scale = sqrt(horizon(1)^2 + horizon(2)^2);
horizon = horizon/scale;

%% Plot vanishing points
figure; imshow(im);
hold on;

plot(vp_1(1), vp_1(2), '*r');
plot(vp_2(1), vp_2(2), '*r')

% plot(-202.3586, 215.3724, '*r');
% plot(1.3715*1.0e3, 0.2306*1.0e3, '*r')
% plot(1e3*0.5031, 4.8670*1e3, '*r');
axis equal
axis image
line([vp_1(1), vp_2(1)], [vp_1(2), vp_2(2)]);

%% Measure height
%% Record reference object height
disp(' ')
disp('Click for reference object ... first bottom then top please ...')
[x1,y1] = ginput(1);
[x2,y2] = ginput(1);

plot([x1 x2], [y1 y2], 'y');

b0 = [x1 y1 1];
t0 = [x2 y2 1];

% compute reference object height
height_ref = 182.88;
% 5 feet, 6 inches = 167.64cm
% 6 feet = 182.88cm

%% Record target object
disp(' ')
disp('Click for target object ... first bottom then top please ...')
[x1,y1] = ginput(1);
[x2,y2] = ginput(1);

plot([x1 x2], [y1 y2], 'g');

b = [x1 y1 1];
r = [x2 y2 1];

% compute target object height
img_height_tar = y2 - y1;

%% compute line bb0, vt0
bottom_line = real(cross(b0', b'));
v = real(cross(bottom_line, horizon));
v = v / v(3);

top_line = real(cross(v', t0'));
vertical_line = real(cross(r', b'));
t = real(cross(top_line', vertical_line'));
t = t / t(3);

%% draw lines 
plot([v(1) b0(1)], [v(2) b0(2)], 'm');
plot([v(1) t0(1)], [v(2) t0(2)], 'm');
plot([v(1) t(1)], [v(2) t(2)], 'm');
plot([b(1) t(1)], [b(2) t(2)], 'c');
plot([b(1) v(1)], [b(2) v(2)], 'm');


%% Compute height of target object

left_up = norm(t - b) * norm(vp_3' - r);
left_down = norm(r - b) * norm(vp_3' - t);
H = height_ref;

height_tar = (H * left_down) / left_up