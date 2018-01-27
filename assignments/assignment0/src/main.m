clc
% imname = {'00125v.jpg', '00149v.jpg', '00153v.jpg', '00351v.jpg', '00398v.jpg', '01112v.jpg'};
% Change the file name to get results
imname = '00125v.jpg';

% The ratio for cropping
ratio_crop = 0.08;

% Range for the image to shift
shift_pts = 40;

% read image
im_in = imread(imname);

% Convert image to double precision
im_removed = im2double(im_in);

% Divide the image horizontally into the 3 images
[height, width] = size(im_removed);
border = floor(height/3);

blue   = im_removed(1:(border), :);
green  = im_removed((border+1):(2*border), :);
red    = im_removed((2*border+1):(3*border), :);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal approach


% normal function: align three channels without any displacements
% normal_way = normal(red, green, blue);
result_normal = cat(3, red, green, blue);
figure, imshow(result_normal)
% imwrite(result_normal, strcat('normal_',imname))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SSD approach


% make green, red the template, 1st trial
[shifted_green_1, xg_1, yg_1] = im_align(blue, green, ratio_crop, shift_pts);
[shifted_red_1, xr_1, yr_1]   = im_align(blue, red,   ratio_crop, shift_pts);
fprintf('The displacement for green channel in the first trial is (%d, %d).\n', xg_1, yg_1);
fprintf('The displacement for red channel in the first trial is (%d, %d).\n', xr_1, yr_1);

result1 = cat(3, shifted_red_1, shifted_green_1, blue);
figure, imshow(result1)
% imwrite(result1, strcat('ssd_1st_',imname))


% make blue, red the template, 2nd trial
[shifted_blue_2, xb_2, yb_2]= im_align(green, blue, ratio_crop, shift_pts);
[shifted_red_2, xr_2, yr_2]  = im_align(green, red,   ratio_crop, shift_pts);
fprintf('The displacement for blue channel in the second trial is (%d, %d).\n', xb_2, yb_2);
fprintf('The displacement for red channel in the second trial is (%d, %d).\n', xr_2, yr_2);

result2 = cat(3, shifted_red_2, green, shifted_blue_2);
figure, imshow(result2)
% imwrite(result2, strcat('ssd_2nd_',imname))


% make blue, red the template, 3rd trial
[shifted_blue_3, xb_3, yb_3] = im_align(red, blue, ratio_crop, shift_pts);
[shifted_green_3,xg_3, yg_3] = im_align(red, green,   ratio_crop, shift_pts);
fprintf('The displacement for blue channel in the third trial is (%d, %d).\n', xb_3, yb_3);
fprintf('The displacement for green channel in the third trial is (%d, %d).\n', xg_3, yg_3);

result3 = cat(3, red, shifted_green_3, shifted_blue_3);
figure, imshow(result3)
% imwrite(result3, strcat('ssd_3rd_',imname))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NCC approach


% make blue as the reference
[shifted_green_ncc_b, xg_b, yg_b] = shift_image(green, blue);
[shifted_red_ncc_b, xr_b, yr_b]   = shift_image(red, blue);
fprintf('The displacement for green channel is (%d, %d).\n', xg_b, yg_b);
fprintf('The displacement for red channel is (%d, %d).\n', xr_b, yr_b);

result_ncc_b = cat(3, shifted_red_ncc_b, shifted_green_ncc_b, blue);
figure, imshow(result_ncc_b)
% imwrite(result_ncc_b, strcat('ncc_b_',imname))


% make green as the reference
[shifted_blue_ncc_g, xb_g, yb_g] = shift_image(blue, green);
[shifted_red_ncc_g, xr_g, yr_g]   = shift_image(red, green);
fprintf('The displacement for blue channel is (%d, %d).\n', xb_g, yb_g);
fprintf('The displacement for red channel is (%d, %d).\n', xr_g, yr_g);

result_ncc_g = cat(3, shifted_red_ncc_g, green, shifted_blue_ncc_g);
figure, imshow(result_ncc_g)
% imwrite(result_ncc_g, strcat('ncc_g_',imname))


% make red as the reference
[shifted_green_ncc_r, xg_r, yg_r] = shift_image(green, red);
[shifted_blue_ncc_r, xb_r, yb_r]   = shift_image(blue, red);
fprintf('The displacement for green channel is (%d, %d).\n', xg_r, yg_r);
fprintf('The displacement for blue channel is (%d, %d).\n', xb_r, yb_r);

result_ncc_r = cat(3, red, shifted_green_ncc_r, shifted_blue_ncc_r);
figure, imshow(result_ncc_r)
% imwrite(result_ncc_r, strcat('ncc_r_',imname))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%