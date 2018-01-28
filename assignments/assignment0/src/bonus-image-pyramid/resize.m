function scaled_img = resize(img, scaling)
	% Scale the image for building the image pyramid
	scaled_img = imresize(img, scaling);

end
