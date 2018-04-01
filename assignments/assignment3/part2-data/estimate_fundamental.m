function matches = estimate_fundamental(I1, I2)
    
    I1 = im2double(rgb2gray(I1));
    I2 = im2double(rgb2gray(I2));
    points1 = detectHarrisFeatures(I1);
    points2 = detectHarrisFeatures(I2);
    
    [features1, valid_points1] = extractFeatures(I1, points1);
    [features2, valid_points2] = extractFeatures(I2, points2);
    % Match the features.

    indexPairs = matchFeatures(features1,features2);
    % Retrieve the locations of the corresponding points for each image.

    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);
    % matchedPoints1.Location
    matches = [matchedPoints1.Location matchedPoints2.Location];
    
    [inliers, num_of_inliers, mean_of_residual] = RANSAC(matches);
    fprintf('this is mean_of_residual: %f \n', mean_of_residual);
    
    final_matches = [];
    for i = 1:num_of_inliers
        final_matches = [final_matches; matches(inliers(i), :)];
    end
end