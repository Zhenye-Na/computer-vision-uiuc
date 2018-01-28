function [shifted_img, BestRow, BestCol] = shift_image(template, A)
    
    % Use matlab built-in function normxcorr2 to compute correlation matrix
    cc = normxcorr2(template, A);

    % Find the max value and index of cc(:)
    [maxc, imax] = max(abs(cc(:)));

    % Use ind2sub find the real index
    [ypeak, xpeak] = ind2sub(size(cc), imax);


    % Find displacement and return
    [row, col] = size(template);
    BestRow = ypeak - (row - 1);
    BestCol = xpeak - (col - 1);

    % Shift the image
    shifted_img = circshift(template, [BestRow, BestCol]);

end