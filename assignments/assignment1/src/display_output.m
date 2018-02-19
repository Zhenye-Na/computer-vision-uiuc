%% Template by: Arun Mallya and Svetlana Lazebnik, 2014
%% Spring 2018 CS 543 Assignment 1
%% Zhenye Na

function display_output(albedo, height_map)
% NOTE: [h, w] is the size of the input images.
% albedo: [h, w] matrix of albedo.
% height_map: [h, w] matrix of surface heights.


	% some cosmetic transformations to make 3D model look better
	[hgt, wid] = size(height_map);
	[X,Y] = meshgrid(1:wid, 1:hgt);
	H = flipud(fliplr(height_map));
	A = flipud(fliplr(albedo));

	figure, imshow(albedo);
	title('Albedo');

	figure;
	mesh(H, X, Y, A);
	axis equal;
	xlabel('Z')
	ylabel('X')
	zlabel('Y')
	title('Height Map')
	view(-60,20)
	colormap(gray)
	set(gca, 'XDir', 'reverse')
	set(gca, 'XTick', []);
	set(gca, 'YTick', []);
	set(gca, 'ZTick', []);

	
end

