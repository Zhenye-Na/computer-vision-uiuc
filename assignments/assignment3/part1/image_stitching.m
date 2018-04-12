function panorama = image_stitching(im_left, im_right)

    %% Turn off "Warning: Image is too big to fit on screen; displaying at ** "
    warning('off', 'Images:initSize:adjustingMag');
    
    %% 0. Parameters Settings

    % Size of neighborhoods
    neighborhoods = 5;

    % Input images
    % im_left = 'data/uttower/uttower_left.jpg';
    % im_right = 'data/uttower/uttower_right.jpg';
    % im_left = '/Users/macbookpro/Downloads/WechatIMG3.jpeg';
    % im_right = '/Users/macbookpro/Downloads/WechatIMG4.jpeg';

    
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

    
    %% Filtering and Edge detection (optional)

    filtering = 0;
    if filtering
        
        % Create the gaussian filter with hsize = [5 5] and sigma = 2   
        sigma = 5;
        hsize = [2*ceil(2*sigma)+1 2*ceil(2*sigma)+1];
        G = fspecial('gaussian',hsize,sigma);

        % Filter it
        im_gauss_filt_left = imfilter(img_left, G, 'same');
        im_gauss_filt_right = imfilter(img_right, G, 'same');

        figure; imshow(im_gauss_filt_left);
        figure; imshow(im_gauss_filt_right);

        % Edge detection
        img_left_edge = edge(im_gauss_filt_left, 'canny', [0.05 0.1]);
        img_right_edge = edge(im_gauss_filt_right, 'canny', [0.05 0.1]);
        
        if ndims(img_left_edge) == 3
            img_left_edge = im2double(rgb2gray(img_left_edge));
        else
            img_left_edge = im2double(img_left_edge);
        end

        if ndims(img_right_edge) == 3
            img_right_edge = im2double(rgb2gray(img_right_edge));
        else
            img_right_edge = im2double(img_right_edge);
        end
        
        figure; imshow(img_left_edge);
        figure; imshow(img_right_edge);
        
    end
    
    
    %% 2. Detect feature points in both images.

    if filtering
        [left_r, left_c] = feature_detect(img_left_edge, neighborhoods, 3, 0.04, 3, 0);
        [right_r, right_c] = feature_detect(img_right_edge, neighborhoods, 3, 0.04, 3, 0);
    else  
        [left_r, left_c] = feature_detect(img_left, neighborhoods, 3, 0.04, 3, 0);
        [right_r, right_c] = feature_detect(img_right, neighborhoods, 3, 0.04, 3, 0);
    end
    

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

    
    % select the top few hundred descriptor pairs
    % with the smallest pairwise distances
    for i = 1:total
        [r, c] = find(distance == min(min(distance)));
        if(length(r) == 1)
            matches = [matches; left_r(r), left_c(r), right_r(c), right_c(c)];
            distance(r,:) = 6666;
            distance(:,c) = 6666;
        end
    end
    
    
    %% 6. Run RANSAC to estimate a homography mapping one image onto the other. 
    % Report the number of inliers and the average residual for the inliers 
    % (squared distance between the point coordinates in one image and the 
    % transformed coordinates of the matching point in the other image). 
    % Also, display the locations of inlier matches in both images.

    [inliers, num_of_inliers, mean_of_residual, H] = RANSAC(matches);
    
    fprintf('mean_of_residual: %f \n', mean_of_residual);
    
    final_matches = [];
    for i = 1:num_of_inliers
        final_matches = [final_matches; matches(inliers(i), :)];
    end
    
    % Show pairwise image features matching
    features_show(img_left_rgb, img_right_rgb, matches, final_matches)
    
    T = maketform('projective', H);
    
    [~, xdata_range, ydata_range] = imtransform(img_left_rgb, T, 'nearest');
    xdata = [min(1, xdata_range(1)), max(size(img_right_rgb, 2), xdata_range(2))];
    ydata = [min(1, ydata_range(1)), max(size(img_right_rgb, 1), ydata_range(2))];
    
    img_left_t = imtransform(img_left_rgb, T, 'nearest', 'XData', xdata, 'YData', ydata);
    img_right_t = imtransform(img_right_rgb, maketform('affine', eye(3)), 'nearest', 'XData', xdata,'YData',ydata);
    
    
    %% 8. Create a new image big enough to hold the panorama and composite the two
    % images into it. You can composite by simply averaging the pixel values 
    % where the two images overlap. Your result should look something like 
    % this (but hopefully with a more precise alignment):

    % Size of output image
    [height, width, channels] = size(img_left_t);

    panorama = img_left_t;
    
    for i = 1:height * width * channels
        if (panorama(i) == 0)
            panorama(i) = img_right_t(i);
        elseif(panorama(i) ~= 0 && img_right_t(i) ~= 0)
            panorama(i) = (img_left_t(i) + img_right_t(i)) / 2;
        end
    end

    
    %% Show the stitching result and matches
    figure; imshow(panorama);
    figure; showMatchedFeatures(img_left_rgb, img_right_rgb, final_matches(:, 2:-1:1), final_matches(:, 4:-1:3));

end

