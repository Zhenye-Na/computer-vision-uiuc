function  triangulate(P1_dir, P2_dir, matches_dir)

%     P1 = load('library1_camera.txt');
%     P2 = load('library2_camera.txt');
%     matches = load('library_matches.txt'); 
%     P1 = load('house1_camera.txt');
%     P2 = load('house2_camera.txt');
%     matches = load('house_matches.txt'); 

    P1 = load(P1_dir);
    P2 = load(P2_dir);
    matches = load(matches_dir);
    
    num_of_matches = size(matches,1);

    % null space of projection matrix
    C1 = null(P1, 'r');
    C1 = C1(1:3, :);

    C2 = null(P2, 'r');
    C2 = C2(1:3, :);

    coord_3d = zeros(num_of_matches, 3);
    for i = 1:num_of_matches
        x1 = [0,                  -1,         matches(i, 2); 
              1,                   0,         -matches(i, 1);
              -matches(i, 2), matches(i, 1),         0];

        x2 = [0,                  -1,         matches(i, 4); 
              1,                   0,         -matches(i, 3);
              -matches(i, 4), matches(i, 3),         0];

        D = [x1 * P1; x2 * P2];
        [~, ~, V] = svd(D); 
        X = V(:,end);
        
        coord_3d(i, 1:3) = [X(1) / X(4), X(2) / X(4), X(3) / X(4)];
    end

    figure; plot3(coord_3d(:,1),coord_3d(:, 2),coord_3d(:, 3), '.b');
    hold on;
    xlabel('x'); ylabel('y'); zlabel('z');
    plot3(C1(1), C1(2), C1(3), 'r*');
    plot3(C2(1), C2(2), C2(3), 'r*');
    text(C1(1), C1(2), C1(3), 'CC1','Color','red','FontSize',10);
    text(C2(1), C2(2), C2(3), 'CC2','Color','red','FontSize',10);
    axis equal;
    
    residual_1 = 0;
    residual_2 = 0;

    for i = 1:num_of_matches
        X1 = P1 * [coord_3d(i, 1:3) 1]';
        residual_1  = residual_1 + sqrt(dist2([X1(1)/X1(3) X1(2)/X1(3)], [matches(i, 1) matches(i, 2)]));
        x2 = P2 * [coord_3d(i, 1:3) 1]';
        residual_2  = residual_2 + sqrt(dist2([x2(1)/x2(3) x2(2)/x2(3)], [matches(i, 3) matches(i, 4)]));
    end

    fprintf('residual_1: %f \n', residual_1);
    fprintf('residual_2: %f \n', residual_2);

end