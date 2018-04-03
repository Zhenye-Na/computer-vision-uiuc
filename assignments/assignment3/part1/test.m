dinfo = dir('/Users/macbookpro/Downloads/LunchRoom/LunchRoom');
names_cell = {dinfo.name};

filename = strcat('/Users/macbookpro/Downloads/LunchRoom/LunchRoom', '/', names_cell);

filename = filename(4:end);

num_of_images = size(filename, 2);

im_1 = filename{1};
img1 = imread(im_1);

im_2 = filename{2};
img2 = imread(im_2);

figure; imshow(img1);
figure; imshow(img2);


panorama_1 = image_stitching(im_1, im_2);
imwrite(panorama_1,'data/lunchroom/panorama_1.jpg', 'jpg');
panorama_1 = 'data/lunchroom/panorama_1.jpg';


for i = 3:num_of_images
    im = filename{i};

    panorama = image_stitching(panorama_1, im);
    imwrite(panorama,'data/lunchroom/panorama.jpg', 'jpg');
    panorama = 'data/lunchroom/panorama.jpg';
    
end