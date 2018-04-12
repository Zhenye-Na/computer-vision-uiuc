function [inliers, num_of_inliers, mean_of_residual, H_re] = RANSAC(matches)

    % threshold
    threshold = 5;
    
    % num of iterations
    iterations = 250;

    % Use four matches to initialize the homography in each iteration. 
    num_of_samples = 4;
    n = 1;    
    num_of_matches = size(matches, 1);

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
        [~, ~, V] = svd(A);
        H = V(:, end);
        H_re = reshape(H, 3, 3);
        
        num_of_inliers = 0;
        inliers = [];
        residual = [];
        for i = 1:num_of_matches
            X =  H_re' * [matches(i, 2); matches(i, 1); 1];
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
    num_of_inliers


end