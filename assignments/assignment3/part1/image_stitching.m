% function image_stitching(im_left, im_right)

    % Turn off "Warning: Image is too big to fit on screen; displaying at ** "
    warning('off', 'Images:initSize:adjustingMag');
    %% 0. Parameters Settings

    % Size of neighborhoods
    neighborhoods = 9;

    % Input images
    % im_left = 'part1-data/uttower_left.jpg';
    % im_right = 'part1-data/uttower_right.jpg';


    %% 1. Load both images, convert to double and to grayscale.

    img_left_rgb = imread(im_left);
    img_right_rgb = imread(im_right);

    if ndims(img_left_rgb) == 3
        img_left = im2double(rgb2gray(img_left_rgb));
    else
        img_left = im2double(img_left_rgb);
    end

    if ndims(img_right_rgb) == 3
        img_right = im2double(rgb2gray(img_right_rgb));
    else
        img_right = im2double(img_right_rgb);
    end

    % Size of images
    [height_left, width_left] = size(img_left);
    [height_right, width_right] = size(img_right);


    %% 2. Detect feature points in both images.

    [left_r, left_c] = feature_detect(img_left, neighborhoods, 3, 0.04, 3, 0);
    [right_r, right_c] = feature_detect(img_right, neighborhoods, 3, 0.04, 3, 0);
    

    [no_of_corners_left, ~] = size(left_c);
    [no_of_corners_right, ~] = size(right_c);


    %% 3. Extract local neighborhoods around every keypoint in both images, and
    % form descriptors simply by "flattening" the pixel values in each neighborhood 
    % to one-dimensional vectors. Experiment with different neighborhood sizes to
    % see which one works the best. If you're using your Laplacian detector, use
    % the detected feature scales to define the neighborhood scales. 

    descriptor_left = extract_descriptors(img_left, neighborhoods, left_r, left_c, no_of_corners_left);
    descriptor_right = extract_descriptors(img_right, neighborhoods, right_r, right_c, no_of_corners_right);


    
    %% 4. Compute distances between every descriptor in one image and every 
    % descriptor in the other image. In MATLAB, you can use dist2.m for 
    % fast computation of Euclidean distance. If you are not using SIFT 
    % descriptors, you should experiment with computing normalized correlation, 
    % or Euclidean distance after normalizing all descriptors to have zero mean
    % and unit standard deviation.
    % 

    % Normalize to zero mean and unit variance
    norm_descriptor_left = zscore(descriptor_left');
    norm_descriptor_left = norm_descriptor_left';

    norm_descriptor_right = zscore(descriptor_right');
    norm_descriptor_right = norm_descriptor_right';

    % Compute distance
    distance = dist2(norm_descriptor_left, norm_descriptor_right);    
    
    
    %% 5. Select putative matches based on the matrix of pairwise descriptor 
    % distances obtained above. You can select all pairs whose descriptor 
    % distances are below a specified threshold, or select the top few hundred 
    % descriptor pairs with the smallest pairwise distances.
    
    [~, tmp_l, ~] = harris(img_left, 3, 0.04, 3, 0);
    [~, tmp_r, ~] = harris(img_right, 3, 0.04, 3, 0);


    % No. of corners in left_image and right_image respectively. 
    [num1, ~] = size(tmp_l);
    [num2, ~] = size(tmp_r);

    total = min([num1, num2, 250]);
    matches = [];

    for i = 1:total
        [r, c] = find(distance == min(min(distance)));
        if(length(r) == 1)
            matches = [matches; left_r(r), left_c(r), right_r(c), right_c(c)];
            distance(r,:) = 100;
            distance(:,c) = 100;
        end
    end

    
    %% 6. Run RANSAC to estimate a homography mapping one image onto the other. 
    % Report the number of inliers and the average residual for the inliers 
    % (squared distance between the point coordinates in one image and the 
    % transformed coordinates of the matching point in the other image). 
    % Also, display the locations of inlier matches in both images.


    [inliers, num_of_inliers, mean_of_residual, H] = RANSAC(250, 2, matches);

    final_matches = [];
    for i = 1:num_of_inliers
        final_matches = [final_matches; matches(inliers(i), :)];
    end
    
    
    % Show pairwise image features matching
    features_show(img_left_rgb, img_right_rgb, matches, final_matches)
    
    T = maketform('projective', H);
    
    [tmp, xdata_range, ydata_range] = imtransform(img_left_rgb, T, 'nearest');
    xdata = [min(1, xdata_range(1)), max(size(img_right_rgb, 2), xdata_range(2))];
    ydata = [min(1, ydata_range(1)), max(size(img_right_rgb, 1), ydata_range(2))];
    
    img_left_t = imtransform(img_left_rgb, T, 'nearest','XData', xdata, 'YData', ydata);
    img_right_t = imtransform(img_right_rgb, maketform('affine', eye(3)), 'nearest', 'XData', xdata,'YData',ydata);

    
    
    %% 8. Create a new image big enough to hold the panorama and composite the two
    % images into it. You can composite by simply averaging the pixel values 
    % where the two images overlap. Your result should look something like 
    % this (but hopefully with a more precise alignment):

    % Size of output image
    [height, width, channels] = size(img_left_t);

    output = img_left_t;
    for i = 1:height * width * channels
        if (output(i) == 0)
            output(i) = img_right_t(i);
        elseif(output(i) ~= 0 && img_right_t(i) ~= 0)
            output(i) = (img_left_t(i) + img_right_t(i)) / 2;
        end
    end

    figure; imshow(output);
    figure; showMatchedFeatures(img_left_rgb, img_right_rgb, final_matches(:, 2:-1:1), final_matches(:, 4:-1:3));


% end

