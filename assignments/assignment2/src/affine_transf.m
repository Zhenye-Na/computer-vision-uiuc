% Assignment 2: Scale-space blob detection
% Zhenye Na (zna2)
% 3/6/2018

% img filename: butterfly.jpg, einstein.jpg, fishes.jpg, flower.jpg
% frog.jpg, gta5.jpg, sunflowers.jpg, tnj.jpg, music.jpg

% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
% Query the last warning to acquire the identifier.  For example: 
% warnStruct = warning('query', 'last');
% msgid_integerCat = warnStruct.identifier
% MATLAB:concatenation:integerInteraction
warning('off', 'Images:initSize:adjustingMag');

% clear all
% Read in image and convert to double and then grayscale
[img, map] = imread('../data/sunflowers.jpg');
img = rgb2gray(img);
img = im2double(img);


[h, w] = size(img);             % Image size
threshold = 0.15;               % Define threshold
k = 1.25;                       % Increasing factor of k
levels = 1;                     % Define number of iterations
initial_sigma = 2;              % Define scale for LoG
sigma = 2;

dx = [-1 0 1; -1 0 1; -1 0 1];  % Derivative masks
dy = dx';

Ix = conv2(img, dx, 'same');    % Image derivatives
Iy = conv2(img, dy, 'same');

% Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
% minimum size 1x1.
g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);

% Smoothed squared image derivatives
Ix2 = conv2(Ix.^2, g, 'same');
Iy2 = conv2(Iy.^2, g, 'same');
Ixy = conv2(Ix.*Iy, g, 'same');

% Perform LoG filter to image for several levels
% [h,w] - dimensions of image, n - number of levels in scale space

tic
% for i = 1:levels
% Generate a Laplacian of Gaussian filter / scale normalization
LoG = fspecial('log', 2 * ceil(3 * sigma) + 1, sigma);
% Filter the img with LoG
scale_space = abs(imfilter(img, LoG, 'replicate', 'same').*(sigma^2));
toc

% suppressed_space = zeros(h,w,levels);
suppressed_space = ordfilt2(scale_space,9,ones(3,3)); 
survive_space = suppressed_space;

% Compute second moment matrix of the image

rad_l = [];
rad_s = [];

for i=1:size(Ix2,1)
    for j=1:size(Ix2,2)
        temp = zeros(2);
        temp(1) = Ix2(i,j);
        temp(2) = Ixy(i,j);
        temp(3) = Ixy(i,j);
        temp(4) = Iy2(i,j);
        lambda = eig(temp);
        if i == 1 && j == 1
            if lambda(1) > lambda(2)
                rad_l = lambda(1);
                rad_s = lambda(2);
            else
                rad_s = lambda(1);
                rad_l = lambda(2);
            end
        else
            if lambda(1) > lambda(2)
                rad_l = [rad_l, lambda(1)];
                rad_s = [rad_s, lambda(2)];
            else
                rad_s = [rad_s, lambda(1)];
                rad_l = [rad_l, lambda(2)];
            end
        end
    end
end

% Reshape
rad_l = reshape(rad_l, [h, w]);
rad_s = reshape(rad_s, [h, w]);

cx = []; cy = []; rad1 = []; rad2 = [];
for i=1:h
    for j=1:w
        if i == 1 && j == 1
            if survive_space(i,j) >= threshold
                cx = j;
                cy = i;
                rad1 = rad_l(i,j) * sigma;
                rad2 = rad_s(i,j) * sigma;
            end
        else
            if survive_space(i,j) >= threshold
                cx = [cx, j];
                cy = [cy, i];
                rad1 = [rad1, rad_l(i,j)* sigma * 10];
                rad2 = [rad2, rad_s(i,j)* sigma * 10];
            end
        end
    end
end


show_ellipse_circles(img, cy', cx', rad1', rad2', threshold, initial_sigma, k);