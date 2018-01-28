function y = ssd(img1, img2)
    % Compute ssd score
    y = sumsqr(img2 - img1);
end
