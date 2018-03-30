% function stitching_img = img_stitching(im_left, im_right)

% 
% 0. Parameters Settings
% 

% Size of neighborhoods
neighborhoods = 3;

% Input images
im_left = 'part1-data/uttower_left.jpg';
im_right = 'part1-data/uttower_right.jpg';

% Size of images
[row_left, col_left] = size(img_left);
[row_right, col_right] = size(img_right);

%
% 1. Load both images, convert to double and to grayscale.
%

img_left = imread(im_left);
img_right = imread(im_right);

if ndims(img_left) == 3
    img_left = im2double(rgb2gray(img_left));
else
    img_left = im2double(img_left);
end

if ndims(img_right) == 3
    img_right = im2double(rgb2gray(img_right));
else
    img_right = im2double(img_right);
end

% 
% 2. Detect feature points in both images.
% 
% r  - row coordinates of corner points.  -> x
% c  - column coordinates of corner points.  -> y
% 

[left_corner, left_r, left_c] = harris(img_left, 3, 0.04, 3, 0);
[right_corner, right_r, right_c] = harris(img_right, 3, 0.04, 3, 0);


% 
% No. of corners in left_image and right_image respectively.
% 

[no_of_corners_left, ~] = size(left_c);
[no_of_corners_right, ~] = size(right_c);



% 
% 3. Extract local neighborhoods around every keypoint in both images, and
% form descriptors simply by "flattening" the pixel values in each neighborhood 
% to one-dimensional vectors. Experiment with different neighborhood sizes to
% see which one works the best. If you're using your Laplacian detector, use
% the detected feature scales to define the neighborhood scales. 
% 


% For left image

descriptor_left = zeros(no_of_corners_left, (2 * neighborhoods + 1)^2);

for i=1:no_of_corners_left
    descriptor_left(i, :) = reshape(img_left(left_r - neighborhoods:left_r + neighborhoods, left_c - neighborhoods:left_c + neighborhoods), 1, (2 * neighborhoods + 1)^2);
end


% For right image

descriptor_right = zeros(no_of_corners_right, (2 * neighborhoods + 1)^2);

for i=1:no_of_corners_right
    descriptor_right(i, :) = reshape(img_right(right_r - neighborhoods:right_r + neighborhoods, right_c - neighborhoods:right_c + neighborhoods), 1, (2 * neighborhoods + 1)^2);
end



% 
% 4. Compute distances between every descriptor in one image and every 
% descriptor in the other image. In MATLAB, you can use dist2.m for 
% fast computation of Euclidean distance. If you are not using SIFT 
% descriptors, you should experiment with computing normalized correlation, 
% or Euclidean distance after normalizing all descriptors to have zero mean
% and unit standard deviation.
% 

distance = dist2(descriptor_left, descriptor_right);



% 
% 5. Select putative matches based on the matrix of pairwise descriptor 
% distances obtained above. You can select all pairs whose descriptor 
% distances are below a specified threshold, or select the top few hundred 
% descriptor pairs with the smallest pairwise distances.
%  






% 
% 6. Run RANSAC to estimate a homography mapping one image onto the other. 
% Report the number of inliers and the average residual for the inliers 
% (squared distance between the point coordinates in one image and the 
% transformed coordinates of the matching point in the other image). 
% Also, display the locations of inlier matches in both images.
% 






% 
% 7. Warp one image onto the other using the estimated transformation. 
% To do this in MATLAB, you will need to learn about maketform and 
% imtransform functions.
% 












% 
% 8. Create a new image big enough to hold the panorama and composite the two
% images into it. You can composite by simply averaging the pixel values 
% where the two images overlap. Your result should look something like 
% this (but hopefully with a more precise alignment):
% 





% end