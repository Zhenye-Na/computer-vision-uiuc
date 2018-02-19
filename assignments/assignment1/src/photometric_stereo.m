function [albedo_image, surface_normals] = photometric_stereo(imarray, light_dirs)
% imarray: [h, w, Nimages] array of images. (Nimages = no. of images)
% light_dirs: [Nimages, 3] array of light source directions.
% albedo_image: [h, w] albedo image.
% surface_normals: [h, w, 3] array of unit surface normals.


	%% <<< fill in your code below >>>
	% Get the size of `imarray`
	[height, width, Nimages] = size(imarray);
	npix = height * width;
    I = zeros(Nimages, npix);
    
	% Implement linear model
	for i = 1:Nimages
	    I(i,:) = reshape(imarray(:,:,i), 1, npix);
	end

	% Solve least square equations
	g = light_dirs \ I;
    
    % Initialization
    albedo = zeros(1, npix);
    normal = zeros(3, npix);
	
	% Compute albedo by computing the norm of g
	for i = 1:npix
	    albedo(:,i) = norm(g(:,i));
	    normal(:,i) = g(:,i)./albedo(:,i);
	end

	% Reshape image
	albedo_image = reshape(albedo, height, width);
	surface_normals = cat(3, reshape(normal(1,:),height, width), reshape(normal(2,:),height, width), reshape(normal(3,:),height, width));


end

