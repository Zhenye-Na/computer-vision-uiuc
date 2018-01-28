function y = ssd(img1, img2, exclude)
    
    % Crop some of the borders to make the ssd more precise
    img1_revised = crop(img1, exclude);
    img2_revised = crop(img2, exclude);
    
    % Compute ssd score
    y = sumsqr(img2_revised - img1_revised);
end