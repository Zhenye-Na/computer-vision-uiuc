function F = fit_fundamental(matches, method)
    
    if method == 'normalized'
        [matches(:, 1:2), T1] = noramlize(matches(:, 1:2));
        [matches(:, 3:4), T2] = noramlize(matches(:, 3:4));
    elseif method == 'unnormalized'
        T1 = eye(3);
        T2 = eye(3);
    else
        fprintf('No such method, do you wanna create this? ...');
        quit cancel;
    end
    
    num_of_matches = size(matches, 1);
    inliers = (1: num_of_matches)';
    A = generate_matrix(matches, inliers);
    
    [~, ~, V] = svd(A); 
    F = V(:,end);
    F = (reshape(F, 3, 3))';
    
    [U, S, V] = svd(F);
    S(3, 3) = 0; % rank 2
    F = U * S * V';
    F = T2'* F * T1;
    
    residual = [];
    for i = 1: num_of_matches
        X = F * [matches(i, 1), matches(i, 2), 1]';
        residual = [residual; abs([matches(i, 3),matches(i, 4), 1] * X)];
    end 

end