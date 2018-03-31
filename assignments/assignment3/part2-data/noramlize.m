function [matches, T] = noramlize(matches)
    
    avg = mean(matches, 1);
    
    matches(:,1) = matches(:,1) - avg(1);
    matches(:,2) = matches(:,2) - avg(2);
    
    dist = sqrt(matches(:,1).^2 + matches(:,2).^2);
    std = mean(dist);
    
    scale = 2/std;
    matches = matches * scale;
    
    T = [scale, 0, -scale * avg(1); 0, scale, -scale * avg(2); 0, 0, 1]; 
end