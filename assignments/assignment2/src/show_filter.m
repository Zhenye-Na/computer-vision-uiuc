% plot 3D
g1=fspecial('log', 15, 2);
g2=Gaussian_filter(15,2);
g3=Gaussian_filter(15,4);
figure(1);
subplot(1,2,1);surf(g1);title('LoG filter size = 15, sigma = 2');
subplot(1,2,2);surf(g3 - g2);title('DoG filter size = 15, sigma = 2, k = 2');
% subplot(1,3,3);surf(g3 - g2);title('filter size = 50, sigma = 11');