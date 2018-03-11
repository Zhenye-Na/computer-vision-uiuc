% Assignment 2: Scale-space blob detection
% Zhenye Na (zna2)
% 3/6/2018

% img filename: butterfly.jpg, einstein.jpg, fishes.jpg, Florist.jpg
% frog.jpg, gta5.jpg, sunflowers.jpg, tnj.jpg, music.jpg


% Read in image and convert to double and then grayscale
img = imread('../data/butterfly.jpg');
img = rgb2gray(img);
img = im2double(img);


% Image size
[h, w] = size(img);
% Define threshold
threshold = 0.05;
% Increasing factor of k
k = 1.25;
% Define number of iterations
levels = 12;
% Define parameters for LoG
initial_sigma = 2;
sigma = 2;
% hsize = 2 * ceil(2 * sigma) + 1;



% Perform LoG filter to image for several levels
% [h,w] - dimensions of image, n - number of levels in scale space
scale_space = zeros(h, w, levels);
tic
for i = 1:levels
    % Generate a Laplacian of Gaussian filter and scale normalization
    LoG = fspecial('log', 2 * floor(3*sigma) + 1, sigma) .* (sigma^2);
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
    % hsize = 2 * ceil(sigma) + 1;
    % Downsample the img
    img_copy = imresize(img, 1/(k^i), 'bicubic');
    
    
%     % GENERATE GIF IN MATLAB
%     % Capture the plot as an image
%     h = figure;
%     imshow(scale_space(:,:,i), map);
%     frame = getframe(h);
%     im = frame2im(frame);
%     [imind, cm] = rgb2ind(im, 256);
%     
%     % WRITE TO THE GIF FILE
%     if i == 1
%         imwrite(imind, cm, 'music.gif', 'gif','LoopCount',Inf,'DelayTime',1)
%     else
%         imwrite(imind, cm, 'music.gif', 'gif','WriteMode','append','DelayTime',1);
%     end
    
    
end
toc




% Perform nonmaximum suppression in each 2D slice
suppressed_space = zeros(h,w,levels);
for i = 1:levels
    suppressed_space(:,:,i) = ordfilt2(scale_space(:,:,i),9,ones(3)); 
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
survive_space = zeros(h,w,levels);
for i = 1:levels
    survive_space(:,:,i) = (maxima_space == scale_space(:,:,i));
    survive_space(:,:,i) = survive_space(:,:,i) .* img;
end
% survive_space = 



% Find all the coordinates and corresponding sigma
% % Find index and corresponding radius


for num = 1:levels
    [c,r] = find(survive_space(:,:,num) >= threshold);
    rad = sqrt(2) * initial_sigma * k^num;
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