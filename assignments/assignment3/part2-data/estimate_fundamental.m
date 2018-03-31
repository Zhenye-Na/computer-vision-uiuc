function final_matches = estimate_fundamental(I1, I2)

    % Size of neighborhoods
    neighborhoods = 3;

    %% 1. Load both images, convert to double and to grayscale.

    if ndims(I1) == 3
        img_left = im2double(rgb2gray(I1));
    else
        img_left = im2double(I1);
    end

    if ndims(I2) == 3
        img_right = im2double(rgb2gray(I2));
    else
        img_right = im2double(I2);
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
    
    [~, tmp_l, ~] = harris(img_left, 3, 0.05, 3, 0);
    [~, tmp_r, ~] = harris(img_right, 3, 0.05, 3, 0);


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

    [inliers, num_of_inliers, mean_of_residual, H] = RANSAC(250, 2, matches);
    
    fprintf('mean_of_residual: %f', mean_of_residual);
    
    final_matches = [];
    for i = 1:num_of_inliers
        final_matches = [final_matches; matches(inliers(i), :)];
    end
end