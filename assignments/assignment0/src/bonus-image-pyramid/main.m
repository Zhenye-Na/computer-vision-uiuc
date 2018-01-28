clc
% 01047u, 01861a, 01657u
im = '01657u';

imname = strcat(im, '.tif');

% read image
im_in = imread(imname);

% Convert image to double precision
im_removed = im2double(im_in);

% Divide the image horizontally into the 3 images
[height, width] = size(im_removed);
border = floor(height/3);

blue   = im_removed(1:(border), :);
green  = im_removed((border+1):(2*border), :);
red    = im_removed((2*border+1):(3*border), :);


% Scaling parameter
scaling = 1/2;

% Use image pyramid, shifting the images to get the best result
Gr = pyramid_shift(green, blue, scaling, 3);
Rr = pyramid_shift(red, blue, scaling, 3);

% Perform the aligment
green = circshift(green, Gr);
red = circshift(red, Rr);

warning('off', 'Images:initSize:adjustingMag');
result = cat(3, red, green, blue);
% figure, imshow(result)
imwrite(result, strcat(im, '.jpg'))

