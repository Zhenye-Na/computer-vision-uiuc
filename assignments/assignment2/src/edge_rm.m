% Assignment 2: Blob Detection using Scale-space 
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
[img, map] = imread('../data/butterfly.jpg');
img = rgb2gray(img);
img = im2double(img);


[h, w] = size(img);             % Image size
threshold = 0.15;               % Define threshold
k = 1.25;                       % Increasing factor of k
levels = 12;                    % Define number of iterations
initial_sigma = 2;              % Define scale for LoG
sigma = 2;


% Reference whether pixel is on the edge
ref = edge(img, 'canny');

scale_space = zeros(h, w, levels);
tic
for i = 1:levels
    % Generate a Laplacian of Gaussian filter and scale normalization
    LoG = fspecial('log', 2 * floor(2*sigma) + 1, sigma) .* (sigma^2);
    if i == 1
        % Filter the img with LoG
        scale_space(:,:,i) = (imfilter(img, LoG, 'same', 'replicate')).^2;
    else
        % Filter the img with LoG
        response = abs(imfilter(img_copy, LoG, 'same', 'replicate'));
        scale_space(:,:,i) = imresize(response, [h w], 'bicubic');
    end
    % Increase scale by a factor k
    sigma = sigma * k;
    % Downsample img
    img_copy = imresize(img, 1/(k^i), 'bicubic');
    
end
toc


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





% Perform nonmaximum suppression in each 2D slice
suppressed_space = zeros(h,w,levels);
for i = 1:levels
    suppressed_space(:,:,i) = ordfilt2(scale_space(:,:,i),9,ones(3)); 
end


% Perform nonmaximum suppression in scale space and apply threshold
% nonmax_space(:,:,num) = suppressed_space(:,:,num) .* (suppressed_space(:,:,num) >= threshold);
maxima_space = max(suppressed_space, [], 3);
survive_space = zeros(h,w,levels);
for i = 1:levels
    survive_space(:,:,i) = (maxima_space == scale_space(:,:,i));
    survive_space(:,:,i) = survive_space(:,:,i) .* img;
end


% implement an additional thresholding step that computes the Harris 
% response at each detected Laplacian region and rejects the regions 
% that have only one dominant gradient orientation 


% Find all the coordinates and corresponding sigma
% % Find index and corresponding radius


cx = []; cy = []; radius = [];
for num = 1:levels
    rad = sqrt(2) * initial_sigma * k^num;
    for i=1:size(Ix2,1)
        for j=1:size(Ix2,2)
            dx = [-1 0 1; -1 0 1; -1 0 1];  % Derivative masks
            dy = dx';
            
            Ix = conv2(survive_space(:,:,num), dx, 'same');    % Image derivatives
            Iy = conv2(survive_space(:,:,num), dy, 'same');
            
            % Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
            % minimum size 1x1.
            g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);
            
            % Smoothed squared image derivatives
            Ix2 = conv2(Ix.^2, g, 'same');
            Iy2 = conv2(Iy.^2, g, 'same');
            Ixy = conv2(Ix.*Iy, g, 'same');

            
            temp = zeros(2);
            temp(1) = Ix2(i,j);
            temp(2) = Ixy(i,j);
            temp(3) = Ixy(i,j);
            temp(4) = Iy2(i,j);
            lambda = eig(temp);
            
            
            % Compute Harris response
            R = lambda(1) * lambda(2) - 0.05 * (lambda(1) + lambda(2)).^2;
            if R > 0 && i == 1 && j == 1
                cx = i;
                cy = j;
                radius = rad;
            elseif R > 0
                cx = [cx; i];
                cy = [cy; j];
                radius = [radius; rad];
            end
        end
    end
end
            

show_all_circles(img, cy, cx, radius, threshold, initial_sigma, k);