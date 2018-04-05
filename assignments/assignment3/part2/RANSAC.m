function [tmp_matches, num_of_inliers, mean_of_residual] = RANSAC(matches)

    iterations = 100;
    num_of_matches = size(matches, 1);

    % Use four matches to initialize the homography in each iteration. 
    num_of_samples = 6;
    n = 1;

    while(n < iterations)
        if num_of_samples == 6
            inliers = randsample(num_of_matches, num_of_samples);
        end
        tmp_matches = [];
        for i = 1:size(inliers, 1)
            tmp_matches = [tmp_matches; matches(inliers(i), :)];
        end
        
        F = fit_fundamental(tmp_matches, 'normalized');
        L = (F * [matches(:,1:2) ones(num_of_matches,1)]')'; 
        L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3);
        pt_line_dist = sum(L .* [matches(:,3:4) ones(num_of_matches,1)],2);
        closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);


        inliers = [];
        residual = [];
        for i = 1:num_of_matches
            distance_pts = sqrt(dist2(closest_pt(i,:), matches(i, 3:4)));
            if(distance_pts < 30)
                inliers = [inliers; i];
                residual = [residual; distance_pts];
            end
        end


        if (size(inliers, 1) < 10)
            num_of_samples = 6;
        else
           num_of_samples = size(inliers, 1);
           n = n + 1;
        end
    end

    mean_of_residual = mean(residual);
    num_of_inliers = size(inliers, 1); 

end