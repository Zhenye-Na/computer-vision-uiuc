function  height_map = get_surface(surface_normals, image_size, method)
% surface_normals: [h, w, 3] array of unit surface normals.
% image_size: [h, w] of output height map/image.
% height_map: height map of object.

    
    %% <<< fill in your code below >>> %%
    % Get the size of images
    height = image_size(1);
    width = image_size(2);

    % Generate Normals
    N1 = surface_normals(:,:,1);
    N2 = surface_normals(:,:,2);
    N3 = surface_normals(:,:,3);
    
    % Compute p-value and q-value (take the derivative)
    p = N1 ./ N3;
    q = N2 ./ N3;


    %%   Algorithm for Integration: 
    %%
    %%   Top left corner of height map is zero 
    %%   For each pixel in the left column of height map
    %%       height value = previous height value + corresponding q value 
    %%   end
    %%   For each row For each element of the row except for leftmost
    %%       height value = previous height value + corresponding p value end 
    %%   end
    %%


    %%   cumsum(A,1) works on successive elements in the columns of A and returns the cumulative sums of each column.
    %%   cumsum(A,2) works on successive elements in the rows of A and returns the cumulative sums of each row.
    

    switch method
        
        % Integrate first the rows, then the columns.
        case 'column'
            tic
            % Make sure the (1,1) element is 0
            temp = zeros(height, width);
            
            % Integrate the first row with p-value
            temp(1,2:end) = cumsum(p(1,2:end), 2);
            temp(2:end,:) = q(2:end,:);
            
            % Integrate columns with q-value
            height_map = cumsum(temp, 1);
            toc
            

        % Integrate first along the columns, then the rows.
        case 'row'
            tic
            % Make sure the (1,1) element is 0
            temp = zeros(height, width);
            
            % Integrate the first column with q-value
            temp(2:end,1) = cumsum(q(2:end,1));
            temp(:,2:end) = p(:,2:end);
            
            % Integrate rows with p-value
            height_map = cumsum(temp,2);
            toc
            
            
        % Average of the first two options.
        case 'average'
            tic
            % Integrating first the rows, then the columns.
            temp1 = zeros(height, width); 
            temp1(1,2:end) = cumsum(p(1,2:end), 2);
            temp1(2:end,:) = q(2:end,:);
            height_map1 = cumsum(temp1);
            
            
            % Integrating first along the columns, then the rows.
            temp2 = zeros(height, width);
            temp2(2:end,1) = cumsum(q(2:end,1));
            temp2(:,2:end) = p(:,2:end);
            height_map2 = cumsum(temp2,2);
            
            % Average of the first two options.
            height_map = (height_map1 + height_map2)*0.5;
            toc


        % Average of multiple random paths.
        case 'random'
            tic
            % # of random paths
            n=25;

            % Initialize height_map
            height_map = zeros(height, width);

            for row = 1:height
                for col = 1:width
                    % Make sure (1,1) element of height_map is 0
                    if (row == 1 && col == 1)
                        height_map(row, col) = 0;
                    else
                        % Generate random paths
                        for i = 1:n
                            % Cummulative sum of p and q
                            csum = 0;
                            
                            % count = row + col
                            count = 1;
                            
                            % Random number -> random direction
                            % The first input to randi indicates the largest integer in the 
                            % sampling interval (the smallest integer in the interval is 1).
                            R = randi(2, row+col, 1);
                            
                            % Start point
                            w = 1;
                            h = 1;
                            
                            % Loop until reach destination
                            while(w < col || h < row)
                                % If first column, vertical direction 
                                if w >= col
                                    R(count)=2;
                                end
                                
                                % If first row, horizontal direction
                                if h >= row
                                    R(count) = 1;
                                end 
                                
                                % Update cummulative sum, Meanwhile
                                % Generate random paths
                                if R(count) == 1
                                    csum = csum + p(h,w);
                                    w = w + 1;
                                else
                                    csum = csum + q(h,w);
                                    h = h + 1;
                                end
                                
                                % Update for next step
                                count = count + 1;
                            end
                            
                            % Integrate over paths
                            height_map(row, col) = csum + height_map(row, col); 
                        end
                        
                        % Compute average
                        height_map(row, col) = height_map(row, col) / n;
                    end
                end
            end
            toc

    end

end

