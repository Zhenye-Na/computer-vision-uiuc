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


% Image size
[h, w] = size(img);
% Define threshold
threshold = 0.25;
% Increasing factor of k
k = 1.25;
% Define number of iterations
levels = 12;
% Define parameters for LoG
initial_sigma = 2;
sigma = 2;



% Perform LoG filter to image for several levels
% [h,w] - dimensions of image, n - number of levels in scale space
scale_space = zeros(h, w, levels);
tic
for i = 1:levels
    % Generate a Laplacian of Gaussian filter / scale normalization
    LoG = fspecial('log', 2 * ceil(3 * sigma) + 1, sigma);
    % Filter the img with LoG
    scale_space(:,:,i) = abs(imfilter(img, LoG, 'replicate', 'same').*(sigma^2));
    % Increase scale by a factor k
    sigma = sigma * k;
    % hsize = 2 * ceil(sigma) + 1;
end
toc

% Perform nonmaximum suppression in each 2D slice
suppressed_space = zeros(h,w,levels);
for i = 1:levels
    suppressed_space(:,:,i) = ordfilt2(scale_space(:,:,i),9,ones(3,3)); 
end


% Perform nonmaximum suppression in scale space and apply threshold
% nonmax_space(:,:,num) = suppressed_space(:,:,num) .* (suppressed_space(:,:,num) >= threshold);

maxima_space = zeros(h, w, levels);
% for num = 1:levels
%     if num == 1
%         maxima_space(:,:,num) = max(suppressed_space(:, :, num:num + 1), [], 3);
%     elseif num == levels
%         maxima_space(:,:,num) = max(suppressed_space(:, :, num - 1:num), [], 3);
%     else
%         maxima_space(:,:,num) = max(suppressed_space(:, :, num - 1:num + 1), [], 3);
%     end
%     maxima_space(:,:,num) = ((maxima_space(:,:,num) == scale_space(:,:,num)) .* img);
% end

maxima_space = max(suppressed_space, [], 3);
survive_space = zeros(h,w,levels);
for i = 1:levels
    survive_space(:,:,i) = (maxima_space == scale_space(:,:,i));
    survive_space(:,:,i) = survive_space(:,:,i) .* img;
end
% survive_space = 



% Find all the coordinates and corresponding sigma
% [row, col] = size(survive_space(:,:,1));
% idx = 1;
% cx = []; cy = []; rad = [];
% for num = 1:levels
%     for i = 1:h
%         for j = 1:w
%             if(survive_space(i,j,num) >= threshold) 
%                 cx(idx) = i;
%                 cy(idx) = j;
%                 rad(idx) = sqrt(2) * initial_sigma^num; 
%                 idx = idx + 1;
%             end
%         end
%     end
% end





% % Find index and corresponding radius
% cx = [];
% cy = [];
% rad = [];
% 
% maxima_space = zeros(h, w, levels);
% indicator_space = zeros(h, w, levels);
% survive_space = zeros(h, w, levels);
% idx = 1;
% for num = 1:levels
%     % Check whether entries greater than threshold value
%     indicator_space(:,:,num) = (maxima_space(:,:,num) >= threshold);
%     survive_space(:,:,num) = indicator_space(:,:,num) .* maxima_space(:,:,num);
%     
%     [row, col] = size(survive_space(:,:,num));
%     for i = 1:row
%         for j = 1:col
%             if (survive_space(i,j,num) ~= 0)
%                 cx(idx) = i;
%                 cy(idx) = j;
%                 rad(idx)= sqrt(2) * initial_sigma^num;
%                 idx = idx + 1;
%             end
%         end
%     end
%     
% end

% max_space = (maxima_space >= threshold);

for num = 1:levels
    [c,r] = find(survive_space(:,:,num) >= threshold);
    rad = sqrt(2) * initial_sigma * k^(num-1);
    if num == 1
        cx = c;
        cy = r;
        radius = rad .* ones(size(r,1), 1);
    else
        cx = [cx; c];
        cy = [cy; r];
        radius = [radius; rad .* ones(size(r,1), 1)];
    end
end
%[c,r] = find(max_space);


show_all_circles(img, cy, cx, radius, threshold, initial_sigma, k);