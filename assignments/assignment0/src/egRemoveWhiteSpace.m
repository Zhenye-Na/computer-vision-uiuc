clc
% imname = {'00125v.jpg', '00149v.jpg', '00153v.jpg', '00351v.jpg', '00398v.jpg', '01112v.jpg'};
% Change the file name to get results
imname = '00149v.jpg';

% read image
im_in = imread(imname);

% Convert image to double precision
im_removed = RemoveWhiteSpace(im_in);
im_double = im2double(im_removed);

% figure, imshow(im_in)
% figure, imshow(im_double)

imwrite(im_double, strcat('cropped_', imname));

fprintf('The size of original image is (%d, %d).\n',size(im_in))
fprintf('The size of cropped image is (%d, %d).\n',size(im_double))
