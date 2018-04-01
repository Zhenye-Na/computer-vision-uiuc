function [r, c] = feature_detect(image, neighborhoods, sigma, thresh, radius, disp_option)

    [height, width] = size(image);
    % Use Harris detector
    [~, r, c] = harris(image, sigma, thresh, radius, disp_option);

    [num_of_corners, ~] = size(c);

    new_r = [];
    new_c = [];
    for i = 1:num_of_corners
        if((r(i) > neighborhoods) && (c(i) > neighborhoods) && (r(i) < height - neighborhoods - 1) && (c(i) < width - neighborhoods - 1))
            new_r = [new_r; r(i)];
            new_c = [new_c; c(i)];
        end
    end
    
    r = new_r;
    c = new_c;
end