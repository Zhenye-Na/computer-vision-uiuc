function [shifted_img, BestRow, BestCol] = shift_image(template, A)
    cc = normxcorr2(template, A);

    % find the max and index of cc(:)
    [maxc, imax] = max(abs(cc(:)));

    % ind2sub find the real index
    [ypeak, xpeak] = ind2sub(size(cc), imax);


    % find displacement
    [row, col] = size(template);
    BestRow = ypeak - (row - 1);
    BestCol = xpeak - (col - 1);

    shifted_img = circshift(template, [BestRow, BestCol]);


end