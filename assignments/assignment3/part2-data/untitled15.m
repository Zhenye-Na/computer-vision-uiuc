P1 = load('house1_camera.txt');
P1 = load('house2_camera.txt');

%matches = load('house_matches.txt'); 
% P1 = load('library1_camera.txt');
% P2 = load('library2_camera.txt');

% matches = load('library_matches.txt'); 
N = size(matches,1);

coordinate_3d = zeros(N, 3);
for i = 1:N
    x1_cross = [    0               -1          matches(i, 2); 
                    1               0          -matches(i, 1);
                -matches(i, 2)  matches(i, 1)        0       ];
    x2_cross = [    0               -1          matches(i, 4); 
                    1               0          -matches(i, 3);
                -matches(i, 4)  matches(i, 3)        0       ];
    D = [x1_cross*P1; x2_cross*P2];
    % solve for DX = 0
    [U,S,V]=svd(D); 
    X = V(:,end);
    coordinate_3d(i, 1:3) = [X(1)/X(4), X(2)/X(4), X(3)/X(4)];
end
%P=[M|?MC]
M1 = P1(1:3, 1:3)*-1;
M1C = P1(1:3, 4);
P1_coordinate = inv(M1)*M1C;

M2 = P2(1:3, 1:3) * -1;
M2C = P2(1:3, 4);
P2_coordinate = inv(M2) * M2C;

figure();
plot3(coordinate_3d(:, 3),coordinate_3d(:, 1),coordinate_3d(:, 2), '.');
hold on;
xlabel('z');
ylabel('x');
zlabel('y');
set(gca,'XDir','reverse');
%set(gca,'YDir','reverse')
plot3(P1_coordinate(3), P1_coordinate(1), P1_coordinate(2), 'ro');
plot3(P2_coordinate(3), P2_coordinate(1), P2_coordinate(2), 'ro');
text(P1_coordinate(3), P1_coordinate(1), P1_coordinate(2), 'camera_1');
text(P2_coordinate(3), P2_coordinate(1), P2_coordinate(2), 'camera_2');
axis equal;

total_residual_1 = 0;
total_residual_2 = 0;
for i = 1:N
    X1 = P1*[coordinate_3d(i, 1:3) 1]';
    total_residual_1  = total_residual_1 + sqrt(dist2([X1(1)/X1(3) X1(2)/X1(3)], [matches(i, 1) matches(i, 2)]));
    X2 = P2*[coordinate_3d(i, 1:3) 1]';
    total_residual_2  = total_residual_2 + sqrt(dist2([X2(1)/X2(3) X2(2)/X2(3)], [matches(i, 3) matches(i, 4)]));
end
