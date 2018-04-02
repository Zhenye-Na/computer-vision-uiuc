im = imread('CSL.jpg');

figure; imshow(im);
hold on;
plot(-202.3586, 215.3724, '*r');
plot(1.3715*1.0e3, 0.2306*1.0e3, '*r')
axis image
line([-202.3586, 1.3715*1.0e3], [215.3724, 0.2306*1.0e3]);