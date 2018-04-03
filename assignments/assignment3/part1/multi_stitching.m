%% First match
% im_1 = 'data/hill/1.jpg';
% im_2 = 'data/hill/2.jpg';
% im_3 = 'data/hill/3.jpg';

im_1 = 'data/ledge/1.jpg';
im_2 = 'data/ledge/3.jpg';
im_3 = 'data/ledge/2.jpg';


% im_1 = 'data/pier/1.jpg';
% im_2 = 'data/pier/2.jpg';
% im_3 = 'data/pier/3.jpg';

panorama_1 = image_stitching(im_1, im_2);


% imwrite(panorama_1,'data/hill/panorama_1.jpg', 'jpg');
% panorama_1 = 'data/hill/panorama_1.jpg';

imwrite(panorama_1,'data/ledge/panorama_1.jpg', 'jpg');
panorama_1 = 'data/ledge/panorama_1.jpg';

% imwrite(panorama_1,'data/pier/panorama_1.jpg', 'jpg');
% panorama_1 = 'data/pier/panorama_1.jpg';

%% Second match
panorama_2 = image_stitching(panorama_1, im_3);