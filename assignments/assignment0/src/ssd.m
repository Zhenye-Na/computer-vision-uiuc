function y = ssd(img1, img2, exclude)
    img1_revised = crop(img1, exclude);
    img2_revised = crop(img2, exclude);
    y = sumsqr(img2_revised - img1_revised);
end