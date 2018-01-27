function cropped = crop(img, percent)
	[w, h] = size(img);
	src = floor(percent * w);
    dest = floor(percent * h);
    cropped = img(src:w-src, dest:h-dest);
end