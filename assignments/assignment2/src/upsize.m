% Assignment 2: Scale-space blob detection
% Zhenye Na (zna2)
% 3/6/2018

% img filename: butterfly.jpg, einstein.jpg, fishes.jpg, Florist.jpg
% frog.jpg, gta5.jpg, sunflowers.jpg, tnj.jpg, USB2106-2.jpg

tic
clc
% Read in image and convert to double and then grayscale
img = imread('../data/butterfly.jpg');
img = im2double(img);
img = rgb2gray(img);

% Image size
[h, w] = size(img);
% Increasing factor of k
k = 2;
% Define number of iterations
levels = 12;
% Define parameters for LoG
% hsize = 
% sigma = 

% Scale space representation
% [h,w] - dimensions of image, n - number of levels in scale space
scale_space = zeros(h, w, levels); 

for i = 1:levels
    % Generate a Laplacian of Gaussian filter and scale normalization
    LoG = fspecial('log', hsize, sigma) .* sigma .^ 2;
    % Filter the img with LoG
    scale_space(:,:,i) = imfilter(img, LoG, 'same', 'replicate');

end

% show_all_circles(img, cy, cx, rad );

toc