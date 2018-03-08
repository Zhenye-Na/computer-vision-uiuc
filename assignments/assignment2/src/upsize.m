% Assignment 2: Scale-space blob detection
% Zhenye Na (zna2)
% 3/6/2018

% img filename: butterfly.jpg, einstein.jpg, fishes.jpg, Florist.jpg
% frog.jpg, gta5.jpg, sunflowers.jpg, tnj.jpg, music.jpg

clc
clear all
% Read in image and convert to double and then grayscale
img = imread('../data/butterfly.jpg');
img = rgb2gray(img);
img = im2double(img);


% Image size
[h, w] = size(img);
% Define threshold
threshold = 0.12;
% Increasing factor of k
k = 1.2;
% Define number of iterations
levels = 6;
% Define parameters for LoG
initial_sigma = 2;
sigma = 2;
% hsize = 2 * ceil(2 * sigma) + 1;


tic
% Perform LoG filter to image for several levels
% [h,w] - dimensions of image, n - number of levels in scale space
scale_space = zeros(h, w, levels); 
for i = 1:levels
    % Generate a Laplacian of Gaussian filter and scale normalization
    LoG = fspecial('log', 2 * ceil(sigma) + 1, sigma);
    % Filter the img with LoG
    scale_space(:,:,i) = (imfilter(img, LoG, 'same', 'replicate')).^2;
    % Increase scale by a factor k
    sigma = sigma * k;
    % hsize = 2 * ceil(sigma) + 1;
end
toc









% Perform nonmaximum suppression in each 2D slice
% nonmax_space = zeros(h, w, levels);
suppressed_space = zeros(h,w,levels);
suppress_order = 3;
for num = 1:levels
    % nonmax_space(:,:,num) = scale_space(:,:,num) .* imregionalmax(scale_space(:,:,num));
    % nonmax_space(:,:,num) = scale_space(:,:,num) .* (maxima_space(:,:,num) >= threshold);
    suppressed_space(:,:,num) = ordfilt2(scale_space(:,:,num),suppress_order^2, ones(suppress_order)); 
    % suppressed_space(:,:,num) = suppressed_space(:,:,num) .* (suppressed_space(:,:,num) == nonmax_space(:,:,num));
end





% Perform nonmaximum suppression in scale space and apply threshold
% nonmax_space(:,:,num) = suppressed_space(:,:,num) .* (suppressed_space(:,:,num) >= threshold);

% maxima_space = zeros(h, w, levels);
% for num = 1:levels
%     if num == 1
%         maxima_space(:,:,num) = max(suppressed_space(:, :, num:num + 1), [], 3);
%     elseif num == levels
%         maxima_space(:,:,num) = max(suppressed_space(:, :, num - 1:num), [], 3);
%     else
%         maxima_space(:,:,num) = max(suppressed_space(:, :, num - 1:num + 1), [], 3);
%     end
%     maxima_space(:,:,num) = (maxima_space(:,:,num) == scale_space(:,:,num)) .* img;
% end

maxima_space = max(suppressed_space, [], 3);
survive_space = zeros(h, w, levels);
for num = 1:levels
    survive_space(:,:,num) = (maxima_space == scale_space(:,:,num));
    survive_space(:,:,num) = survive_space(:,:,num) .* img;
end



% [N,Index]=max(survive_space,[],3); % to find the index values and the CX and CY values.
% si=size(N);
[row, col] = size(survive_space(:,:,num));
id=1;
for num = 1:levels
    for i = 1:row
        for j = 1:col
            if(survive_space(i,j,num) >= threshold) 
                x(id) = i;
                y(id) = j;
                rad(id) = sqrt(2) * initial_sigma^num; 
                id = id + 1;
           end

        end
    end
end




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

% for num = 1:levels
%     [c,r] = find(max_space(:,:,num));
%     cx = [cx;r];
%     cy = [cy;c];
% end
%[c,r] = find(max_space);

show_all_circles(img, y, x, rad);

