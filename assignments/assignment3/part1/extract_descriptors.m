function descriptor = extract_descriptors(image, neighborhoods, left_r, left_c, num_of_corners)
    
    descriptor = zeros(num_of_corners, (2 * neighborhoods + 1)^2);

    for i = 1:num_of_corners
        descriptor(i, :) = reshape(image(left_r(i) - neighborhoods:left_r(i) + neighborhoods, left_c(i) - neighborhoods:left_c(i) + neighborhoods), 1, (2 * neighborhoods + 1)^2);
    end

end