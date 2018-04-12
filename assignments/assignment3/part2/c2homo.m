function homocoord = c2homo(coord)
    [height, ~] = size(coord);
    homocoord = [coord ones(height, 1)];
end