[img, map] = imread('../data/einstein.jpg');
img = rgb2gray(img);
img = im2double(img);


% Image size
[h, w] = size(img);
% Define threshold
threshold = 0.25;
% Increasing factor of k
k = 1.25;
% Define number of iterations
levels = 1;
% Define parameters for LoG
initial_sigma = 2;
sigma = 2;
% hsize = 2 * ceil(2 * sigma) + 1;



dx = [-1 0 1; -1 0 1; -1 0 1];  % Derivative masks
dy = dx';

Ix = conv2(img, dx, 'same');    % Image derivatives
Iy = conv2(img, dy, 'same');

% Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
% minimum size 1x1.
g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);

Ix2 = conv2(Ix.^2, g, 'same');  % Smoothed squared image derivatives
Iy2 = conv2(Iy.^2, g, 'same');
Ixy = conv2(Ix.*Iy, g, 'same');




cim = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps); % Harris corner measure

[U,S,V] = svd(cim);

m = moment(img,2);

% Perform LoG filter to image for several levels
% [h,w] - dimensions of image, n - number of levels in scale space
% scale_space = zeros(h, w, levels);

tic
% for i = 1:levels
% Generate a Laplacian of Gaussian filter / scale normalization
LoG = fspecial('log', 2 * ceil(3 * sigma) + 1, sigma);
% Filter the img with LoG
scale_space = (imfilter(img, LoG, 'replicate', 'same').*(sigma^2)).^2;
% Increase scale by a factor k
sigma = sigma * k;
toc

% suppressed_space = zeros(h,w,levels);
suppressed_space = ordfilt2(scale_space,9,ones(3,3)); 
maxima_space = max(suppressed_space, [], 3);
% survive_space = zeros(h,w,levels);
% for i = 1:levels
survive_space = (maxima_space == scale_space).* img;
%     survive_space = survive_space .* img;
% end



% Compute second moment of the image

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



for i=1:h
    for j=1:w
        if i == 1 && j == 1
            if survive_space(i,j) >= threshold
                cx = j;
                cy = i;
                rad1 = rad_l(i,j);
                rad2 = rad_s(i,j);
            end
        else
            if survive_space(i,j) >= threshold
                cx = [cx, j];
                cy = [cy, i];
                rad1 = [rad1, rad_l(i,j)];
                rad2 = [rad2, rad_s(i,j)];
            end
        end
    end
end

% [c,r] = find(survive_space >= threshold);
% rad = sqrt(2) * initial_sigma;
% cx = c;
% cy = r;
% 
% 
% rad1 = rad .* ones(size(r,1), 1);
% rad2


show_ellipse_circles(img, cy, cx, rad1, rad2, threshold, initial_sigma, k);