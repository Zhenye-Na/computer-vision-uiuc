function cropped = crop(img, percent)
	
	% Get the size of image
	[w, h] = size(img);
	
	% Initiate start point and end point for cropping
	src = floor(percent * w);
    dest = floor(percent * h);
    
    % Crop the image
    cropped = img(src:w-src, dest:h-dest);
end