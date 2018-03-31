% function stitching_img = img_stitching(im_left, im_right)

    % Turn off this warning "Warning: Image is too big to fit on screen; displaying at 33% "
    % To set the warning state, you must first know the message identifier for the one warning you want to enable. 
    % Query the last warning to acquire the identifier.  For example: 
    % warnStruct = warning('query', 'last');
    % msgid_integerCat = warnStruct.identifier
    % msgid_integerCat =
    %    MATLAB:concatenation:integerInteraction
    warning('off', 'Images:initSize:adjustingMag');
    %% 0. Parameters Settings

    % Size of neighborhoods
    neighborhoods = 9;

    % Input images
    im_left = 'part1-data/uttower_left.jpg';
    im_right = 'part1-data/uttower_right.jpg';


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
    % 
    % r  - row coordinates of corner points.  -> x
    % c  - column coordinates of corner points.  -> y


    [left_corner, left_r, left_c] = harris(img_left, 3, 0.04, 3, 0);
    [right_corner, right_r, right_c] = harris(img_right, 3, 0.04, 3, 0);


    % No. of corners in left_image and right_image respectively. 
    [no_of_corners_left, ~] = size(left_c);
    [no_of_corners_right, ~] = size(right_c);


    new_left_r = [];
    new_left_c = [];
    for i = 1:no_of_corners_left
        if((left_r(i) > neighborhoods) && (left_c(i) > neighborhoods) && (left_r(i) < height_left - neighborhoods - 1) && (left_c(i) < width_left - neighborhoods - 1))
            new_left_r = [new_left_r; left_r(i)];
            new_left_c = [new_left_c; left_c(i)];
        end
    end

    new_right_r = [];
    new_right_c = [];
    for i = 1:no_of_corners_right
        if((right_r(i) > neighborhoods) && (right_c(i) > neighborhoods) && (right_r(i) < height_right - neighborhoods - 1) && (right_c(i) < width_right - neighborhoods - 1))
            new_right_r = [new_right_r; right_r(i)];
            new_right_c = [new_right_c; right_c(i)];
        end
    end


    [new_no_of_corners_left, ~] = size(new_left_c);
    [new_no_of_corners_right, ~] = size(new_right_c);


    %% 3. Extract local neighborhoods around every keypoint in both images, and
    % form descriptors simply by "flattening" the pixel values in each neighborhood 
    % to one-dimensional vectors. Experiment with different neighborhood sizes to
    % see which one works the best. If you're using your Laplacian detector, use
    % the detected feature scales to define the neighborhood scales. 


    % For left image
    descriptor_left = zeros(new_no_of_corners_left, (2 * neighborhoods + 1)^2);

    for i = 1:new_no_of_corners_left
        descriptor_left(i, :) = reshape(img_left(new_left_r(i) - neighborhoods:new_left_r(i) + neighborhoods, new_left_c(i) - neighborhoods:new_left_c(i) + neighborhoods), 1, (2 * neighborhoods + 1)^2);
    end


    % For right image
    descriptor_right = zeros(new_no_of_corners_right, (2 * neighborhoods + 1)^2);

    for i = 1:new_no_of_corners_right
        descriptor_right(i, :) = reshape(img_right(new_right_r(i) - neighborhoods:new_right_r(i) + neighborhoods, new_right_c(i) - neighborhoods:new_right_c(i) + neighborhoods), 1, (2 * neighborhoods + 1)^2);
    end

    % points = detectSURFFeatures(img_right);
    % [features, points] = extractFeatures(img_right, points);



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


    total = min([no_of_corners_left, no_of_corners_right, 250]);
    matches = [];

    for i = 1:total
        [r, c] = find(distance == min(min(distance)));
        if(length(r) == 1)
            matches = [matches; new_left_r(r), new_left_c(r), new_right_r(c), new_right_c(c)];
            distance(r,:) = 100;
            distance(:,c) = 100;
        end
    end


    %% 6. Run RANSAC to estimate a homography mapping one image onto the other. 
    % Report the number of inliers and the average residual for the inliers 
    % (squared distance between the point coordinates in one image and the 
    % transformed coordinates of the matching point in the other image). 
    % Also, display the locations of inlier matches in both images.


    threshold = 2;
    iterations = 250;
    num_of_matches = size(matches, 1);

    % Use four matches to initialize the homography in each iteration. 
    num_of_samples = 4;
    n = 1;

    while(n < iterations)
        if num_of_samples == 4
            inliers = randsample(num_of_matches, num_of_samples);
        end
        A = [];
        for i = 1:num_of_samples
            current_match = matches(inliers(i), :);
            xT = [current_match(2), current_match(1), 1];
            A = [A; xT*0, xT, xT*(-current_match(3))];
            A = [A; xT, xT*0, xT*(-current_match(4))];
        end
        
        % Homography fitting calls for homogeneous least squares.
        [U, S, V] = svd(A);
        H = V(:, end);
        
        H1 = reshape(H, 3, 3);
        num_of_inliers = 0;
        inliers = [];
        residual = [];
        for i = 1:num_of_matches
            X =  H1' * [matches(i, 2); matches(i, 1); 1];
            x = X(1) / X(3);
            y = X(2) / X(3);
            if (dist2([x, y], [matches(i, 4), matches(i, 3)]) < threshold)
                inliers = [inliers; i];
                residual = [residual; dist2([x,y], [matches(i, 4), matches(i, 3)])];
                num_of_inliers = num_of_inliers + 1;
            end
        end

        if (num_of_inliers < 15)
            num_of_samples = 4;
        else
           num_of_samples = num_of_inliers;
           n = n + 1;
        end
    end

    mean_of_residual = mean(residual);


    %% 7. Warp one image onto the other using the estimated transformation. 
    % To do this in MATLAB, you will need to learn about maketform and 
    % imtransform functions.


    final_matches = [];
    for i = 1:num_of_inliers
        final_matches = [final_matches; matches(inliers(i), :)];
    end

    figure; imshow(img_left_rgb); hold on;
    scatter(matches(:, 2), matches(:, 1), 'g');
    scatter(final_matches(:, 2), final_matches(:, 1), 'r', '+');
    
    figure; imshow(img_right_rgb); hold on;
    scatter(matches(:, 4), matches(:, 3), 'g');
    scatter(final_matches(:, 4), final_matches(:, 3), 'r', '+');

    T = maketform('projective', H1);
    
    [tmp, xdata_range, ydata_range] = imtransform(img_left_rgb, T, 'nearest');
    xdataout=[min(1, xdata_range(1)), max(size(img_right_rgb, 2),xdata_range(2))];
    ydataout=[min(1, ydata_range(1)), max(size(img_right_rgb, 1),ydata_range(2))];
    
    img_left_t = imtransform(img_left_rgb, T, 'nearest','XData', xdataout, 'YData', ydataout);
    img_right_t = imtransform(img_right_rgb, maketform('affine', eye(3)), 'nearest', 'XData', xdataout,'YData',ydataout);

    
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