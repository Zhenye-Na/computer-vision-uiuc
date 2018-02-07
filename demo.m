%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%(8) Working with the Images and the Matlab Image Processing Toolbox

[I,map]=imread('trees.tif');            % use as it is, Matlab has pre-stored images

figure
imshow(I,map)                           % display it as indexed image w/colormap

I2=ind2gray(I,map);                     % convert it to grayscale

figure
imagesc(I2,[0 1])                       % scale data to use full colormap
                                        %  for values between 0 and 1
colormap('gray')                        % use gray colormap
axis('image')                           % make displayed aspect ratio proportional
                                        %  to image dimensions 

I=imread('football.jpg');               % read a JPEG image into 3D array

figure
imshow(I)
rect=getrect;                           % select rectangle
I2=imcrop(I,rect);                      % crop
I2=rgb2gray(I2);                        % convert cropped image to grayscale
imagesc(I2)                             % scale data to use full colormap
                                        % between min and max values in I2
colormap('gray')
colorbar                                % turn on color bar
impixelinfo                             % display pixel values interactively
truesize                                % display at resolution of one screen pixel
                                        % per image pixel
truesize(2*size(I2))                    % display at resolution of two screen pixels
                                        % per image pixel

I3=imresize(I2,0.5,'bil');              % resize by 50% using bilinear 
                                        %  interpolation
I3=imrotate(I2,45,'bil','crop');        % rotate 45 degrees and crop to
                                        %  original size
I3=double(I2);                          % convert from uint8 to double, to allow
                                        %  math operations
imagesc(I3.^2)                          % display squared image (pixel-wise)
imagesc(log(I3))                        % display log of image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%