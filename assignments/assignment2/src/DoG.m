% Assignment 2: Scale-space blob detection
% Zhenye Na (zna2)
% 3/6/2018

% img filename: butterfly.jpg, einstein.jpg, fishes.jpg, Florist.jpg
% frog.jpg, gta5.jpg, sunflowers.jpg, tnj.jpg, music.jpg

% Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
% To set the warning state, you must first know the message identifier for the one warning you want to enable. 
% Query the last warning to acquire the identifier.  For example: 
% warnStruct = warning('query', 'last');
% msgid_integerCat = warnStruct.identifier
% msgid_integerCat =
% MATLAB:concatenation:integerInteraction
warning('off', 'Images:initSize:adjustingMag');

% clear all
% Read in image and convert to double and then grayscale
img = imread('../data/sunflowers.jpg');
img = rgb2gray(img);
img = im2double(img);

% Parameters initialization
% Image size
[h, w] = size(img);
% Define threshold
threshold = 0.0003;
% Increasing factor of k
k = sqrt(2);
% Define number of iterations
levels = 4;
octave = 3;
% Define parameters for LoG
initial_sigma = 2;
sigma = 2;



tic
% First octave, original image size
scale_space_temp = zeros(h, w ,levels);
img_octave_1 = img;
for i = 1:levels
    filter = fspecial('gaussian', [3 3], sigma);
    filter_response = abs(imfilter(img_octave_1, filter, 'same', 'replicate'));
    scale_space_temp(:,:,i) = filter_response;
    sigma = sigma * k;
end

scale_space_1 = zeros(h, w, levels-1);
for i = 2:levels
    % Substract the previous octave
    scale_space_1(:,:,i-1) = scale_space_temp(:,:,i) - scale_space_temp(:,:,i-1);
end



sigma = initial_sigma * k^2;
% Second octave, original image size
img_octave_2 = imresize(img, 0.5);
scale_space_temp = zeros(size(img_octave_2, 1), size(img_octave_2, 2) ,levels);
for i = 1:levels
    filter = fspecial('gaussian', [3 3], sigma);
    filter_response = abs(imfilter(img_octave_2, filter, 'same', 'replicate'));
    scale_space_temp(:,:,i) = filter_response;
    sigma = sigma * k;
end

scale_space_2 = zeros(size(img_octave_2, 1), size(img_octave_2, 2) ,levels-1);
for i = 2:levels
    % Substract the previous octave
    scale_space_2(:,:,i-1) = scale_space_temp(:,:,i) - scale_space_temp(:,:,i-1);
end



sigma = initial_sigma * k^4;
% Third octave, original image size
img_octave_3 = imresize(img_octave_2, 0.5);
scale_space_temp = zeros(size(img_octave_3, 1), size(img_octave_3, 2) ,levels);
for i = 1:levels
    filter = fspecial('gaussian', [3 3], sigma);
    filter_response = abs(imfilter(img_octave_3, filter, 'same', 'replicate'));
    scale_space_temp(:,:,i) = filter_response;
    sigma = sigma * k;
end

scale_space_3 = zeros(size(img_octave_3, 1), size(img_octave_3, 2) ,levels-1);
for i = 2:levels
    % Substract the previous octave
    scale_space_3(:,:,i-1) = scale_space_temp(:,:,i) - scale_space_temp(:,:,i-1);
end
toc



% Perform Nonmaxima Suppression in octave 1
BW1 = imregionalmax(scale_space_1,26);
BW2 = imregionalmax(scale_space_2,26);
BW3 = imregionalmax(scale_space_3,26);



% Get the maxima element back
Maxima_1 = BW1 .* scale_space_1;
Maxima_2 = BW2 .* scale_space_2;
Maxima_3 = BW3 .* scale_space_3;



% Find x, y and radius of blobs
for num = 1:levels-1
    [c,r] = find(Maxima_1(:,:,num) >= threshold);
    rad = sqrt(2) * initial_sigma * k^(num-1);
    if num == 1
        cx1 = c;
        cy1 = r;
        radius1 = rad .* ones(size(r,1), 1);
    else
        cx1 = [cx1; c];
        cy1 = [cy1; r];
        radius1 = [radius1; rad .* ones(size(r,1), 1)];
    end
end


for num = 1:levels-1
    [c,r] = find(Maxima_2(:,:,num) >= threshold/2);
    rad = sqrt(2) * initial_sigma * k^2 * k^(num-1);
    if num == 1
        cx2 = c;
        cy2 = r;
        radius2 = rad .* ones(size(r,1), 1);
    else
        cx2 = [cx2; c];
        cy2 = [cy2; r];
        radius2 = [radius2; rad .* ones(size(r,1), 1)];
    end
end


for num = 1:levels-1
    [c,r] = find(Maxima_3(:,:,num) >= threshold/8);
    rad = sqrt(2) * initial_sigma * k^4 * k^(num-1);
    if num == 1
        cx3 = c;
        cy3 = r;
        radius3 = rad .* ones(size(r,1), 1);
    else
        cx3 = [cx3; c];
        cy3 = [cy3; r];
        radius3 = [radius3; rad .* ones(size(r,1), 1)];
    end
end



% Select coordinates
ccx = []; ccy = []; raad = [];
for i = 1:size(cx1, 1)
    x = cx1(i);
    y = cy1(i);
    
    x2 = x/2;
    x3 = x/4;
    y2 = y/2;
    y3 = y/4;


    if ismember(x2, cx2) && ismember(y2, cy2) && ismember(x3, cx3) && ismember(y3, cy3)
        ccx = [ccx; x];
        ccy = [ccy; y];
        raad = [raad; radius1(i)];
    end
end

% 
show_all_circles(img, ccy, ccx, raad, threshold, initial_sigma, k);