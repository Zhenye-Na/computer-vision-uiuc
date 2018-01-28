function shift_range = pyramid_shift(image, reference, scaling, N)

	if N == 0
		
        % Find displacement for image based on reference
		shift_range = find_displacement(reference, image, 20);
	else
		
		scaled_image = imresize(image, scaling);
		scaled_reference = imresize(reference, scaling);
        
        shift_range = pyramid_shift(scaled_image, scaled_reference, scaling, N-1) * 1/scaling;
        
        image = circshift(image, shift_range);
        shift_range = shift_range + find_displacement(reference, image, 2);
        
	end


end
