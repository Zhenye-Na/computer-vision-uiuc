function [tran_cord, norm_matches] = noramlize(matches)
    
    avg = mean(matches, 1);
    
    offset = eye(3);
    offset(1, 3) = -avg(1);
    offset(2, 3) = -avg(2);
    
    X = max(abs(matches(:, 1)));
    Y = max(abs(matches(:, 2)));
    
    scale = eye(3);
    scale(1, 1) = 1 / X;
    scale(2, 2) = 1 / Y;
    
    tran_cord = scale * offset;
    norm_matches = (tran_cord * matches')';
    
    
end