function F = fit_fundamental(matches, method)
    
    % preprocess
    matches_1 = c2homo(matches(:, 1:2));
    matches_2 = c2homo(matches(:, 3:4));
    
    if strcmp(method, 'normalized')
        % fprintf('Normalization Method \n');
        [tran_cord_1, norm_matches_1] = noramlize(matches_1);
        [tran_cord_2, norm_matches_2] = noramlize(matches_2);
        matches_1 = norm_matches_1;
        matches_2 = norm_matches_2;
    elseif strcmp(method, 'unnormalized')
        % fprintf('Unnormalization Method \n');
    else
        % fprintf('No such method, do you wanna create this? ... \n');
        % quit cancel;
    end
    
    num_of_matches = size(matches, 1);
    
    u = matches_1(:, 1);
    v = matches_1(:, 2);
    u_p = matches_2(:, 1);
    v_p = matches_2(:, 2);
    
    A = [u_p .* u, u_p .* v, u_p, v_p .* u, v_p .* v, v_p, u, v, ones(num_of_matches, 1)]; 
    
    [~, ~, V] = svd(A); 
    F = V(:,end);
    F = reshape(F, 3, 3);
    
    [U, S, V] = svd(F);
    S(end) = 0; % rank 2 constraint
    F = U * S * V';

    if strcmp(method, 'normalized')
        F = tran_cord_2'* F * tran_cord_1;
    end
    
    
    residual = [];
    for i = 1: num_of_matches
        X = F * [matches(i, 1), matches(i, 2), 1]';
        residual = [residual; abs([matches(i, 3),matches(i, 4), 1] * X)];
    end 
    
    % fprintf('mean_of_residual: %f \n', mean(residual));
end